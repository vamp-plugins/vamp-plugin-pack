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
#include <QDialogButtonBox>
#include <QLabel>
#include <QFont>
#include <QFontInfo>
#include <QTemporaryFile>
#include <QMutex>
#include <QMutexLocker>
#include <QProcess>
#include <QToolButton>
#include <QMessageBox>
#include <QSvgRenderer>
#include <QPainter>
#include <QFontMetrics>

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
    QString licence;
};

QString
identifyLicence(QString libraryBasename)
{
    QString licenceFile = QString(":out/%1_COPYING.txt").arg(libraryBasename);

    QFile f(licenceFile);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        SVCERR << "Failed to open licence file "
               << licenceFile.toStdString() << endl;
        return {};
    }

    QByteArray content = f.readAll();
    f.close();

    QString licenceText = QString::fromUtf8(content);

    QString gpl = "GNU General Public License";
    QString agpl = "GNU Affero General Public License";
    QString apache = "Apache License";
    QString mit = "MIT License";

    // NB these are not expected to correctly identify any licence! We
    // know we have only a limited set here. But we do want to
    // determine this from the actual licence text included with the
    // plugin distribution, not just from e.g. RDF metadata
    
    if (licenceText.contains(gpl.toUpper(), Qt::CaseSensitive)) {
        if (licenceText.contains("Version 3, 29 June 2007")) {
            return QString("%1, version 3").arg(gpl);
        } else if (licenceText.contains("Version 2, June 1991")) {
            return QString("%1, version 2").arg(gpl);
        } else {
            return gpl;
        }
    }
    if (licenceText.contains(agpl.toUpper(), Qt::CaseSensitive)) {
        return agpl;
    }
    if (licenceText.contains(apache)) {
        return apache;
    }
    if (licenceText.contains("Permission is hereby granted, free of charge, to any person")) {
        return mit;
    }

    SVCERR << "Didn't recognise licence for " << libraryBasename << endl;
    
    return {};
}

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

        info.licence = identifyLicence(libId.value);
        SVCERR << "licence = " << info.licence << endl;
        
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

enum class RelativeStatus {
    New,
    Same,
    Upgrade,
    Downgrade,
    TargetNotLoadable
};

QString
relativeStatusLabel(RelativeStatus status) {
    switch (status) {
    case RelativeStatus::New: return QObject::tr("Not yet installed");
    case RelativeStatus::Same: return QObject::tr("Already installed");
    case RelativeStatus::Upgrade: return QObject::tr("Update");
    case RelativeStatus::Downgrade: return QObject::tr("Newer version installed");
    case RelativeStatus::TargetNotLoadable: return QObject::tr("<unknown>");
    }
}

RelativeStatus
getRelativeStatus(LibraryInfo info, QString targetDir)
{
    QString destination = targetDir + "/" + info.fileName;

    RelativeStatus status = RelativeStatus::New;

    SVCERR << "\ngetRelativeStatus: " << info.fileName << ":\n";

    if (QFileInfo(destination).exists()) {

        auto installed = getLibraryPluginVersions(destination);

        SVCERR << " * installed: " << versionsString(installed)
               << "\n * packaged:  " << versionsString(info.pluginVersions)
               << endl;

        status = RelativeStatus::Same;

        if (installed.empty()) {
            status = RelativeStatus::TargetNotLoadable;
        }

        if (isLibraryNewer(installed, info.pluginVersions)) {
            status = RelativeStatus::Downgrade;
        }

        if (isLibraryNewer(info.pluginVersions, installed)) {
            status = RelativeStatus::Upgrade;
        }
    }

    SVCERR << " - relative status: " << relativeStatusLabel(status) << endl;

    return status;
}

void
installLibrary(LibraryInfo info, QString targetDir)
{
    QString library = info.fileName;
    QString source = ":out";
    QFile f(source + "/" + library);
    QString destination = targetDir + "/" + library;

    if (QFileInfo(destination).exists()) {
        auto installed = getLibraryPluginVersions(destination);
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
        QString destination = targetDir + "/" + e;
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

vector<LibraryInfo>
getUserApprovedPluginLibraries(vector<LibraryInfo> libraries,
                               QString targetDir)
{
    QDialog dialog;

    auto mainLayout = new QGridLayout;
    mainLayout->setSpacing(0);
    dialog.setLayout(mainLayout);

    int mainRow = 0;
    
    auto selectionFrame = new QWidget;
    mainLayout->addWidget(selectionFrame, mainRow, 0);
    ++mainRow;
    
    auto selectionLayout = new QGridLayout;
    selectionFrame->setLayout(selectionLayout);
    int selectionRow = 0;
    
    auto checkAll = new QCheckBox;
    checkAll->setChecked(true);
    selectionLayout->addWidget(checkAll, selectionRow, 0, Qt::AlignHCenter);
    ++selectionRow;

    auto checkArrow = new QLabel("&#9660;");
    checkArrow->setTextFormat(Qt::RichText);
    selectionLayout->addWidget(checkArrow, selectionRow, 0, Qt::AlignHCenter);
    ++selectionRow;

    map<QString, QCheckBox *> checkBoxMap; // filename -> checkbox
    map<QString, LibraryInfo> libFileInfo; // filename -> info
    map<QString, RelativeStatus> statuses; // filename -> status

    map<QString, LibraryInfo, function<bool (QString, QString)>>
        orderedInfo
        ([](QString k1, QString k2) {
             return k1.localeAwareCompare(k2) < 0;
         });
    for (auto info: libraries) {
        orderedInfo[info.title] = info;
    }

    int fontHeight = QFontMetrics(checkArrow->font()).height();
    
    QPixmap infoMap(fontHeight, fontHeight);
    QPixmap moreMap(fontHeight * 2, fontHeight * 2);
    infoMap.fill(Qt::transparent);
    moreMap.fill(Qt::transparent);
    QSvgRenderer renderer(QString(":icons/scalable/info.svg"));
    QPainter painter;
    painter.begin(&infoMap);
    renderer.render(&painter);
    painter.end();
    painter.begin(&moreMap);
    renderer.render(&painter);
    painter.end();

    auto shouldCheck = [](RelativeStatus status) {
                           return (status == RelativeStatus::New ||
                                   status == RelativeStatus::Upgrade ||
                                   status == RelativeStatus::TargetNotLoadable);
                       };
    
    for (auto ip: orderedInfo) {

        auto cb = new QCheckBox;
        selectionLayout->addWidget(cb, selectionRow, 0, Qt::AlignHCenter);

        LibraryInfo info = ip.second;

        auto shortLabel = new QLabel(info.title);
        selectionLayout->addWidget(shortLabel, selectionRow, 1);

        RelativeStatus relativeStatus = getRelativeStatus(info, targetDir);
        auto statusLabel = new QLabel(relativeStatusLabel(relativeStatus));
        selectionLayout->addWidget(statusLabel, selectionRow, 2);
        cb->setChecked(shouldCheck(relativeStatus));
        
        auto expand = new QToolButton;
        expand->setAutoRaise(true);
        expand->setIcon(infoMap);
        expand->setIconSize(QSize(fontHeight, fontHeight));
        selectionLayout->addWidget(expand, selectionRow, 3);

        ++selectionRow;

        QString text = QObject::tr("<b>%1</b><br><i>%2</i><br><br>%3<br><br>Library contains:<ul>")
            .arg(info.title)
            .arg(info.maker)
            .arg(info.description);

        int n = 0;
        bool closed = false;
        for (auto title: info.pluginTitles) {
            if (n == 10 && info.pluginTitles.size() > 15) {
                text += QObject::tr("</ul>");
                text += QObject::tr("... and %n other plugins.<br><br>", "",
                                    info.pluginTitles.size() - n);
                closed = true;
                break;
            }
            text += QObject::tr("<li>%1</li>").arg(title);
            ++n;
        }

        if (!closed) {
            text += QObject::tr("</ul>");
        }

        if (info.licence != "") {
            text += QObject::tr("Provided under the %1.<br>").arg(info.licence);
        }
        
        QObject::connect(expand, &QAbstractButton::clicked,
                         [=]() {
                             QMessageBox mbox;
                             mbox.setIconPixmap(moreMap);
                             mbox.setWindowTitle(QObject::tr("Library contents"));
                             mbox.setText(text);
                             mbox.exec();
                         });
        
        checkBoxMap[info.fileName] = cb;
        libFileInfo[info.fileName] = info;
        statuses[info.fileName] = relativeStatus;
    }

    QObject::connect(checkAll, &QCheckBox::toggled,
                     [=](bool toCheck) {
                         for (auto p: checkBoxMap) {
                             p.second->setChecked(toCheck);
                         }
                     });
                     
    auto bb = new QDialogButtonBox(QDialogButtonBox::Ok |
                                   QDialogButtonBox::Cancel |
                                   QDialogButtonBox::Reset);
    mainLayout->addWidget(bb, mainRow, 0);
    ++mainRow;

    mainLayout->setRowStretch(0, 10);
    mainLayout->setColumnStretch(0, 10);
    selectionLayout->setColumnMinimumWidth(0, 50);
    selectionLayout->setColumnStretch(1, 10);

    QObject::connect
        (bb, &QDialogButtonBox::clicked,
         [&](QAbstractButton *button) {

             auto role = bb->buttonRole(button);

             switch (role) {

             case QDialogButtonBox::AcceptRole: {
                 bool downgrade = false;
                 for (const auto &p: checkBoxMap) {
                     if (p.second->isChecked() &&
                         statuses.at(p.first) == RelativeStatus::Downgrade) {
                         downgrade = true;
                         break;
                     }
                 }
                 if (downgrade) {
                     if (QMessageBox::warning
                         (bb, QObject::tr("Downgrade?"),
                          QObject::tr("You have asked to downgrade one or more plugin libraries that are already installed.<br><br>Are you sure?"),
                          QMessageBox::Ok | QMessageBox::Cancel,
                          QMessageBox::Cancel) == QMessageBox::Ok) {
                         dialog.accept();
                     }
                 } else {
                     dialog.accept();
                 }
                 break;
             }

             case QDialogButtonBox::RejectRole:
                 dialog.reject();
                 break;

             case QDialogButtonBox::ResetRole:
                 for (const auto &p: checkBoxMap) {
                     p.second->setChecked(shouldCheck(statuses.at(p.first)));
                 }
                 break;

             default:
                 SVCERR << "WARNING: Unexpected role " << role << endl;
             }
         });
    
    if (dialog.exec() != QDialog::Accepted) {
        SVCERR << "rejected" << endl;
        return {};
    }

    vector<LibraryInfo> approved;
    for (const auto &p: checkBoxMap) {
        if (p.second->isChecked()) {
            approved.push_back(libFileInfo[p.first]);
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
    
    vector<LibraryInfo> toInstall =
        getUserApprovedPluginLibraries(info, target);

    if (!toInstall.empty()) {
        if (!QDir(target).exists()) {
            QDir().mkpath(target);
        }
    }
    
    for (auto lib: toInstall) {
        installLibrary(lib, target);
    }
    
    return 0;
}
