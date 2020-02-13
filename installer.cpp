/* -*- c-basic-offset: 4 indent-tabs-mode: nil -*-  vi:set ts=8 sts=4 sw=4: */
/*
    Copyright (c) 2020 Queen Mary, University of London

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use, copy,
    modify, merge, publish, distribute, sublicense, and/or sell copies
    of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    Except as contained in this notice, the names of the Centre for
    Digital Music and Queen Mary, University of London shall not be
    used in advertising or otherwise to promote the sale, use or other
    dealings in this Software without prior written authorization.
*/

#include <QApplication>
#include <QString>
#include <QFile>
#include <QDir>

#include <QDialog>
#include <QFrame>
#include <QVBoxLayout>
#include <QCheckBox>
#include <QScrollArea>
#include <QDialogButtonBox>
#include <QLabel>
#include <QFont>
#include <QFontInfo>
#include <QTemporaryFile>
#include <QMutex>
#include <QMutexLocker>
#include <QProcess>

#include <vamp-hostsdk/PluginHostAdapter.h>

#include <dataquay/BasicStore.h>
#include <dataquay/RDFException.h>

#include <iostream>
#include <memory>
#include <set>

#include "base/Debug.h"

using namespace std;
using namespace Dataquay;

QString
getDefaultInstallDirectory()
{
    auto pathList = Vamp::PluginHostAdapter::getPluginPath();
    if (pathList.empty()) {
        SVCERR << "Failed to look up Vamp plugin path" << endl;
        return QString();
    }

    auto firstPath = *pathList.begin();
    QString target = QString::fromUtf8(firstPath.c_str(), firstPath.size());
    return target;
}

QStringList
getPluginLibraryList()
{
    QDir dir(":out/");
    auto entries = dir.entryList({ "*.so", "*.dll", "*.dylib" });

    for (auto e: entries) {
        SVCERR << e.toStdString() << endl;
    }

    return entries;
}

void
loadLibraryRdf(BasicStore &store, QString filename)
{
    QFile f(filename);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        SVCERR << "Failed to open RDF resource file "
               << filename.toStdString() << endl;
        return;
    }

    QByteArray content = f.readAll();
    f.close();

    try {
        store.importString(QString::fromUtf8(content), 
                           Uri("file:" + filename),
                           BasicStore::ImportIgnoreDuplicates);
    } catch (const RDFException &ex) {
        SVCERR << "Failed to import RDF resource file "
               << filename.toStdString() << ": " << ex.what() << endl;
    }
}

unique_ptr<BasicStore>
loadLibrariesRdf()
{
    unique_ptr<BasicStore> store(new BasicStore);

    vector<QString> dirs { ":rdf/plugins", ":out" };

    for (auto d: dirs) {
        for (auto e: QDir(d).entryList({ "*.ttl", "*.n3" })) {
            loadLibraryRdf(*store, d + "/" + e);
        }
    }

    return store;
}

struct LibraryInfo {
    QString id;
    QString fileName;
    QString title;
    QString maker;
    QString description;
    QStringList pluginTitles;
    map<QString, int> pluginVersions; // id -> version
};

vector<LibraryInfo>
getLibraryInfo(const Store &store, QStringList libraries)
{
    /* e.g.

       plugbase:library a vamp:PluginLibrary ;
       vamp:identifier "qm-vamp-plugins" ; 
       dc:title "Queen Mary plugin set"
    */

    Triples tt = store.match(Triple(Node(),
                                    Uri("a"),
                                    store.expand("vamp:PluginLibrary")));

    map<QString, QString> wanted; // basename -> full lib name
    for (auto lib: libraries) {
        wanted[QFileInfo(lib).baseName()] = lib;
    }
    
    vector<LibraryInfo> results;
    
    for (auto t: tt) {

        Node libId = store.complete(Triple(t.subject(),
                                           store.expand("vamp:identifier"),
                                           Node()));
        if (libId.type != Node::Literal) {
            continue;
        }
        auto wi = wanted.find(libId.value);
        if (wi == wanted.end()) {
            continue;
        }
        
        Node title = store.complete(Triple(t.subject(),
                                           store.expand("dc:title"),
                                           Node()));
        if (title.type != Node::Literal) {
            continue;
        }

        LibraryInfo info;
        info.id = wi->first;
        info.fileName = wi->second;
        info.title = title.value;
        
        Node maker = store.complete(Triple(t.subject(),
                                           store.expand("foaf:maker"),
                                           Node()));
        if (maker.type == Node::Literal) {
            info.maker = maker.value;
        } else if (maker != Node()) {
            maker = store.complete(Triple(maker,
                                          store.expand("foaf:name"),
                                          Node()));
            if (maker.type == Node::Literal) {
                info.maker = maker.value;
            }
        }
            
        Node desc = store.complete(Triple(t.subject(),
                                          store.expand("dc:description"),
                                          Node()));
        if (desc.type == Node::Literal) {
            info.description = desc.value;
        }

        Triples pp = store.match(Triple(t.subject(),
                                        store.expand("vamp:available_plugin"),
                                        Node()));
        for (auto p: pp) {
            Node ptitle = store.complete(Triple(p.object(),
                                                store.expand("dc:title"),
                                                Node()));
            if (ptitle.type == Node::Literal) {
                info.pluginTitles.push_back(ptitle.value);
            }

            Node pident = store.complete(Triple(p.object(),
                                                store.expand("vamp:identifier"),
                                                Node()));
            Node pversion = store.complete(Triple(p.object(),
                                                  store.expand("owl:versionInfo"),
                                                  Node()));
            if (pident.type == Node::Literal &&
                pversion.type == Node::Literal) {
                bool ok = false;
                int version = pversion.value.toInt(&ok);
                if (ok) {
                    info.pluginVersions[pident.value] = version;
                }
            }
        }
        
        results.push_back(info);
        wanted.erase(libId.value);
    }

    for (auto wp: wanted) {
        SVCERR << "Failed to find any RDF information about library "
               << wp.second << endl;
    }
    
    return results;
}

struct TempFileDeleter {
    ~TempFileDeleter() {
        if (tempFile != "") {
            QFile(tempFile).remove();
        }
    }
    QString tempFile;
};

map<QString, int>
getLibraryPluginVersions(QString libraryFilePath)
{
    static QMutex mutex;
    static QString tempFileName;
    static TempFileDeleter deleter;
    static bool initHappened = false, initSucceeded = false;

    QMutexLocker locker (&mutex);

    if (!initHappened) {
        initHappened = true;

        QTemporaryFile tempFile;
        tempFile.setAutoRemove(false);
        if (!tempFile.open()) {
            SVCERR << "ERROR: Failed to open a temporary file" << endl;
            return {};
        }

        // We can't make the QTemporaryFile static, as it will hold
        // the file open and that prevents us from executing it. Hence
        // the separate deleter.
        
        tempFileName = tempFile.fileName();
        deleter.tempFile = tempFileName;
        
#ifdef Q_OS_WIN32
        QString helperPath = ":out/get-version.exe";
#else
        QString helperPath = ":out/get-version";
#endif        
        QFile helper(helperPath);
        if (!helper.open(QFile::ReadOnly)) {
            SVCERR << "ERROR: Failed to read helper code" << endl;
            return {};
        }
        QByteArray content = helper.readAll();
        helper.close();

        if (tempFile.write(content) != content.size()) {
            SVCERR << "ERROR: Incomplete write to temporary file" << endl;
            return {};
        }
        tempFile.close();

        if (!QFile::setPermissions
            (tempFileName,
             QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner)) {
            SVCERR << "ERROR: Failed to set execute permission on helper "
                   << tempFileName << endl;
            return {};
        }
        
        initSucceeded = true;
    }

    if (!initSucceeded) {
        return {};
    }

    QProcess process;
    process.start(tempFileName, { libraryFilePath });

    if (!process.waitForStarted()) {
        QProcess::ProcessError err = process.error();
        if (err == QProcess::FailedToStart) {
            SVCERR << "Unable to start helper process " << tempFileName << endl;
        } else if (err == QProcess::Crashed) {
            SVCERR << "Helper process " << tempFileName
                   << " crashed on startup" << endl;
        } else {
            SVCERR << "Helper process " << tempFileName
                   << " failed on startup with error code " << err << endl;
        }
        return {};
    }
    process.waitForFinished();

    QByteArray stdOut = process.readAllStandardOutput();
    QByteArray stdErr = process.readAllStandardError();

    QString errStr = QString::fromUtf8(stdErr);
    if (!errStr.isEmpty()) {
        SVCERR << "Note: Helper process stderr follows:" << endl;
        SVCERR << errStr << endl;
        SVCERR << "Note: Helper process stderr ends" << endl;
    }

    QStringList lines = QString::fromUtf8(stdOut).split
        (QRegExp("[\\r\\n]+"), QString::SkipEmptyParts);
    map<QString, int> versions;
    for (QString line: lines) {
        QStringList parts = line.split(":");
        if (parts.size() != 2) {
            SVCERR << "Unparseable output line: " << line << endl;
            continue;
        }
        bool ok = false;
        int version = parts[1].toInt(&ok);
        if (!ok) {
            SVCERR << "Unparseable version number in line: " << line << endl;
            continue;
        }
        versions[parts[0]] = version;
    }

    return versions;
}

bool isLibraryNewer(map<QString, int> a, map<QString, int> b)
{
    // a and b are maps from plugin id to plugin version for libraries
    // A and B. (There is no overarching library version number.) We
    // deem library A to be newer than library B if:
    // 
    // 1. A contains a plugin id that is also in B, whose version in
    // A is newer than that in B, or
    //
    // 2. B is not newer than A according to rule 1, and neither A or
    // B is empty, and A contains a plugin id that is not in B, and B
    // does not contain any plugin id that is not in A
    //
    // (The not-empty part of rule 2 is just to avoid false positives
    // when a library or its metadata could not be read at all.)

    auto containsANewerPlugin = [](const map<QString, int> &m1,
                                   const map<QString, int> &m2) {
                                    for (auto p: m1) {
                                        if (m2.find(p.first) != m2.end() &&
                                            p.second > m2.at(p.first)) {
                                            return true;
                                        }
                                    }
                                    return false;
                                };

    auto containsANovelPlugin = [](const map<QString, int> &m1,
                                   const map<QString, int> &m2) {
                                    for (auto p: m1) {
                                        if (m2.find(p.first) == m2.end()) {
                                            return true;
                                        }
                                    }
                                    return false;
                                };

    if (containsANewerPlugin(a, b)) {
        return true;
    }
    
    if (!containsANewerPlugin(b, a) &&
        !a.empty() &&
        !b.empty() &&
        containsANovelPlugin(a, b) &&
        !containsANovelPlugin(b, a)) {
        return true;
    }

    return false;
}

QString
versionsString(const map<QString, int> &vv)
{
    QStringList pv;
    for (auto v: vv) {
        pv.push_back(QString("%1:%2").arg(v.first).arg(v.second));
    }
    return "{ " + pv.join(", ") + " }";
}

void
installLibrary(QString library, LibraryInfo info, QString target)
{
    QString source = ":out";
    QFile f(source + "/" + library);
    QString destination = target + "/" + library;

    if (QFileInfo(destination).exists()) {
        auto installed = getLibraryPluginVersions(destination);
        SVCERR << "Note: comparing installed plugin versions "
               << versionsString(installed)
               << " to packaged versions "
               << versionsString(info.pluginVersions)
               << ": isLibraryNewer(installed, packaged) returns "
               << isLibraryNewer(installed, info.pluginVersions)
               << endl;
    } else {
        SVCERR << "Note: library " << library
               << " is not yet installed, not comparing versions" << endl;
    }
    
    SVCERR << "Copying " << library.toStdString() << " to "
           << destination.toStdString() << "..." << endl;
    if (!f.copy(destination)) {
        SVCERR << "Failed to copy " << library.toStdString()
               << " to target " << destination.toStdString() << endl;
        return;
    }
    if (!QFile::setPermissions
        (destination,
         QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner |
         QFile::ReadGroup | QFile::ExeGroup |
         QFile::ReadOther | QFile::ExeOther)) {
        SVCERR << "Failed to set permissions on "
               << library.toStdString() << endl;
        return;
    }

    QString base = QFileInfo(library).baseName();
    QDir dir(source);
    auto entries = dir.entryList({ base + "*" });
    for (auto e: entries) {
        if (e == library) continue;
        QString destination = target + "/" + e;
        SVCERR << "Copying " << e.toStdString() << " to "
               << destination.toStdString() << "..." << endl;
        if (!QFile(source + "/" + e).copy(destination)) {
            SVCERR << "Failed to copy " << e.toStdString()
                   << " to target " << destination.toStdString()
                   << " (ignoring)" << endl;
            continue;
        }
        if (!QFile::setPermissions
            (destination,
             QFile::ReadOwner | QFile::WriteOwner |
             QFile::ReadGroup |
             QFile::ReadOther)) {
            SVCERR << "Failed to set permissions on "
                   << destination.toStdString()
                   << " (ignoring)" << endl;
            continue;
        }
    }
}

map<QString, LibraryInfo>
getUserApprovedPluginLibraries(vector<LibraryInfo> libraries)
{
    QDialog dialog;

    auto mainLayout = new QGridLayout;
    mainLayout->setSpacing(0);
    dialog.setLayout(mainLayout);

    int mainRow = 0;
    
    auto checkAll = new QCheckBox;
    checkAll->setChecked(true);
    mainLayout->addWidget(checkAll, mainRow, 0, Qt::AlignHCenter);
    ++mainRow;

    auto checkArrow = new QLabel("&#9660;");
    checkArrow->setTextFormat(Qt::RichText);
    mainLayout->addWidget(checkArrow, mainRow, 0, Qt::AlignHCenter);
    ++mainRow;
    
    auto scroll = new QScrollArea;
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    mainLayout->addWidget(scroll, mainRow, 0, 1, 2);
    mainLayout->setRowStretch(mainRow, 10);
    ++mainRow;

    auto selectionFrame = new QWidget;
    
    auto selectionLayout = new QGridLayout;
    selectionFrame->setLayout(selectionLayout);
    int selectionRow = 0;

    map<QString, QCheckBox *> checkBoxMap; // filename -> checkbox
    map<QString, LibraryInfo> libFileInfo; // filename -> info

    map<QString, LibraryInfo, function<bool (QString, QString)>>
        orderedInfo
        ([](QString k1, QString k2) {
             return k1.localeAwareCompare(k2) < 0;
         });
    for (auto info: libraries) {
        orderedInfo[info.title] = info;
    }

    for (auto ip: orderedInfo) {

        auto cb = new QCheckBox;
        cb->setChecked(true);
        
        selectionLayout->addWidget(cb, selectionRow, 0,
                                   Qt::AlignTop | Qt::AlignHCenter);

        LibraryInfo info = ip.second;
/*
        int n = info.pluginTitles.size();
        QString contents;
        
        if (n > 0) {
            int max = 4;
            QStringList titles;
            for (int i = 0; i < max && i < int(info.pluginTitles.size()); ++i) {
                titles.push_back(info.pluginTitles[i]);
            }
            QString titleText = titles.join(", ");
            if (max < int(info.pluginTitles.size())) {
                titleText = QObject::tr("%1 ...").arg(titleText);
            }
            contents = QObject::tr("Plugins: %1").arg(titleText);
        }
*/        
        QString text = QObject::tr("<b>%1</b><br><i>%2</i><br>%3")
                                .arg(info.title)
                                .arg(info.maker)
                                .arg(info.description);
        
        auto label = new QLabel(text);
        label->setWordWrap(true);
        label->setMinimumWidth(800);
        
        selectionLayout->addWidget(label, selectionRow, 1, Qt::AlignTop);

        ++selectionRow;

        checkBoxMap[info.fileName] = cb;
        libFileInfo[info.fileName] = info;
    }

    scroll->setWidget(selectionFrame);

    QObject::connect(checkAll, &QCheckBox::toggled,
                     [=]() {
                         bool toCheck = checkAll->isChecked();
                         for (auto p: checkBoxMap) {
                             p.second->setChecked(toCheck);
                         }
                     });
                     
    auto bb = new QDialogButtonBox(QDialogButtonBox::Ok |
                                   QDialogButtonBox::Cancel);
    mainLayout->addWidget(bb, mainRow, 0, 1, 2);
    ++mainRow;

    int cw = 50;
    mainLayout->setColumnMinimumWidth(0, cw + 20); //!!!
    mainLayout->setColumnStretch(1, 10);
    selectionLayout->setColumnMinimumWidth(0, cw); //!!!
    selectionLayout->setColumnMinimumWidth(1, 820); //!!!
    selectionLayout->setColumnStretch(1, 10);

    QObject::connect(bb, SIGNAL(accepted()), &dialog, SLOT(accept()));
    QObject::connect(bb, SIGNAL(rejected()), &dialog, SLOT(reject()));
    
    if (dialog.exec() != QDialog::Accepted) {
        SVCERR << "rejected" << endl;
        return {};
    }

    map<QString, LibraryInfo> approved;
    for (const auto &p: checkBoxMap) {
        if (p.second->isChecked()) {
            approved[p.first] = libFileInfo[p.first];
        }
    }
    
    return approved;
}

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    QApplication::setOrganizationName("sonic-visualiser");
    QApplication::setOrganizationDomain("sonicvisualiser.org");
    QApplication::setApplicationName(QApplication::tr("Vamp Plugin Pack Installer"));

#ifdef Q_OS_WIN32
    QFont font(QApplication::font());
    QString preferredFamily = "Segoe UI";
    font.setFamily(preferredFamily);
    if (QFontInfo(font).family() == preferredFamily) {
        font.setPointSize(10);
        QApplication::setFont(font);
    }
#endif

    QString target = getDefaultInstallDirectory();
    if (target == "") {
        return 1;
    }

    QStringList libraries = getPluginLibraryList();

    auto rdfStore = loadLibrariesRdf();

    auto info = getLibraryInfo(*rdfStore, libraries);
    
    map<QString, LibraryInfo> toInstall = getUserApprovedPluginLibraries(info);

    if (!toInstall.empty()) {
        if (!QDir(target).exists()) {
            QDir().mkpath(target);
        }
    }
    
    for (auto lib: toInstall) {
        installLibrary(lib.first, lib.second, target);
    }
    
    return 0;
}
