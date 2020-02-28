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
#include <QPushButton>
#include <QMessageBox>
#include <QSvgRenderer>
#include <QPainter>
#include <QFontMetrics>
#include <QSpacerItem>
#include <QProgressDialog>
#include <QThread>
#include <QDateTime>
#include <QTimer>

#include <vamp-hostsdk/PluginHostAdapter.h>

#include <dataquay/BasicStore.h>
#include <dataquay/RDFException.h>

#include <iostream>
#include <memory>
#include <set>

#include "base/Debug.h"

#include "version.h"

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
    QString page;
    QStringList pluginTitles;
    QString licence;
};

struct Licence
{
    static QString gpl;
    static QString gpl2;
    static QString gpl3;
    static QString agpl;
    static QString apache;
    static QString mit;
};

QString Licence::gpl = "GNU General Public License";
QString Licence::gpl2 = "GNU General Public License, version 2";
QString Licence::gpl3 = "GNU General Public License, version 3";
QString Licence::agpl = "GNU Affero General Public License";
QString Licence::apache = "Apache License";
QString Licence::mit = "MIT License";

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

    // NB these are not expected to identify an arbitrary licence! We
    // know we have only a limited set here. But we do want to
    // determine this from the actual licence text included with the
    // plugin distribution, not just from e.g. RDF metadata
    
    if (licenceText.contains(Licence::gpl.toUpper(), Qt::CaseSensitive)) {
        if (licenceText.contains("Version 3, 29 June 2007")) {
            return Licence::gpl3;
        } else if (licenceText.contains("Version 2, June 1991")) {
            return Licence::gpl2;
        } else {
            return Licence::gpl;
        }
    }
    if (licenceText.contains(Licence::agpl.toUpper(), Qt::CaseSensitive)) {
        return Licence::agpl;
    }
    if (licenceText.contains(Licence::apache)) {
        return Licence::apache;
    }
    if (licenceText.contains("Permission is hereby granted, free of charge, to any person")) {
        return Licence::mit;
    }

    SVCERR << "Didn't recognise licence for " << libraryBasename << endl;
    
    return {};
}

QString
getLicenceURL(QString licence)
{
    if (licence == Licence::gpl ||
        licence == Licence::gpl3) {
        return "https://www.gnu.org/licenses/gpl-3.0.en.html";
    } else if (licence == Licence::gpl2) {
        return "https://www.gnu.org/licenses/old-licenses/gpl-2.0.html";
    } else if (licence == Licence::agpl) {
        return "https://www.gnu.org/licenses/agpl-3.0.html";
    } else if (licence == Licence::apache) {
        return "https://www.apache.org/licenses/LICENSE-2.0";
    } else if (licence == Licence::mit) {
        return "https://opensource.org/licenses/MIT";
    }

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
            
        Node page = store.complete(Triple(t.subject(),
                                          store.expand("foaf:page"),
                                          Node()));
        if (page.type == Node::URI) {
            info.page = page.value;
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

bool
unbundleFile(QString filePath, QString targetPath, bool isExecutable)
{
    SVCERR << "Copying " << filePath.toStdString() << " to "
           << targetPath.toStdString() << "..." << endl;

    // This has to be able to work even if the destination exists, and
    // to do so without deleting it first - e.g. when copying to a
    // temporary file. So we open the file and copy to it ourselves
    // rather than use QFile::copy

    QFile source(filePath);
    if (!source.open(QFile::ReadOnly)) {
        SVCERR << "ERROR: Failed to read bundled file " << filePath << endl;
        return {};
    }
    QByteArray content = source.readAll();
    source.close();

    QFile target(targetPath);
    if (!target.open(QFile::WriteOnly)) {
        SVCERR << "ERROR: Failed to read target file " << targetPath << endl;
        return {};
    }
    if (target.write(content) != content.size()) {
        SVCERR << "ERROR: Incomplete write to target file" << endl;
        return {};
    }
    target.close();

    auto permissions =
        QFile::ReadOwner | QFile::WriteOwner |
        QFile::ReadGroup |
        QFile::ReadOther;

    if (isExecutable) {
        permissions |=
            QFile::ExeOwner |
            QFile::ExeGroup |
            QFile::ExeOther;
    };
    
    if (!QFile::setPermissions(targetPath, permissions)) {
        SVCERR << "Failed to set permissions on "
               << targetPath.toStdString() << endl;
        return false;
    }

    return true;
}

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

        tempFile.close();
        if (!unbundleFile(helperPath, tempFileName, true)) {
            SVCERR << "ERROR: Failed to unbundle helper code" << endl;
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

map<QString, int>
getBundledLibraryPluginVersions(QString libraryFileName)
{
    QString tempFileName;
    TempFileDeleter deleter;

    {
        QTemporaryFile tempFile;
        tempFile.setAutoRemove(false);
        if (!tempFile.open()) {
            SVCERR << "ERROR: Failed to open a temporary file" << endl;
            return {};
        }

        // We can't use QTemporaryFile's auto-remove, as it will hold
        // the file open and that prevents us from executing it. Hence
        // the separate deleter.
        
        tempFileName = tempFile.fileName();
        deleter.tempFile = tempFileName;
        tempFile.close();
    }

    if (!unbundleFile(":out/" + libraryFileName, tempFileName, true)) {
        return {};
    }

    return getLibraryPluginVersions(tempFileName);
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
    case RelativeStatus::TargetNotLoadable: return QObject::tr("Installed version not working");
    default: return {};
    }
}

RelativeStatus
getRelativeStatus(LibraryInfo info, QString targetDir)
{
    QString destination = targetDir + "/" + info.fileName;

    SVCERR << "\ngetRelativeStatus: " << info.fileName << ":\n";

    if (!QFileInfo(destination).exists()) {
        SVCERR << " - relative status: " << relativeStatusLabel(RelativeStatus::New) << endl;
        return RelativeStatus::New;
    }

    RelativeStatus status = RelativeStatus::Same;

    auto packaged = getBundledLibraryPluginVersions(info.fileName);
    auto installed = getLibraryPluginVersions(destination);

    SVCERR << " * installed: " << versionsString(installed)
           << "\n * packaged:  " << versionsString(packaged)
           << endl;

    if (installed.empty()) {
        status = RelativeStatus::TargetNotLoadable;
    }

    if (isLibraryNewer(installed, packaged)) {
        status = RelativeStatus::Downgrade;
    }

    if (isLibraryNewer(packaged, installed)) {
        status = RelativeStatus::Upgrade;
    }

    SVCERR << " - relative status: " << relativeStatusLabel(status) << endl;

    return status;
}

bool
backup(QString filePath, QString backupDir)
{
    QFileInfo file(filePath);
    
    if (!file.exists()) {
        return true;
    }
    
    if (!QDir(backupDir).exists()) {
        QDir().mkpath(backupDir);
    }
    
    QString backup = backupDir + "/" + file.fileName() + ".bak";
    SVCERR << "Note: existing file " << filePath
           << " found, backing up to " << backup << endl;
    if (!QFile(filePath).rename(backup)) {
        SVCERR << "Failed to move " << filePath.toStdString()
               << " to backup " << backup.toStdString() << endl;
        return false;
    }

    return true;
}

QString
installLibrary(LibraryInfo info, QString targetDir)
{
    QString library = info.fileName;
    QString source = ":out";
    QString destination = targetDir + "/" + library;

    static QString backupDirName;
    if (backupDirName == "") {
        // Static so as to be created once - don't go creating a
        // second directory if the clock ticks over by one second
        // between library installs
        backupDirName = 
            QString("saved-%1").arg(QDateTime::currentDateTime().toString
                                    ("yyyyMMdd-hhmmss"));
    }
    QString backupDir = targetDir + "/" + backupDirName;

    if (!QDir(targetDir).exists()) {
        QDir().mkpath(targetDir);
    }

    if (!backup(destination, backupDir)) {
        return QObject::tr("Failed to move aside existing library");
    }

    if (!unbundleFile(source + "/" + library, destination, true)) {
        return QObject::tr("Failed to copy library file to target directory");
    }
    
    QString base = QFileInfo(library).baseName();
    QDir dir(source);
    auto entries = dir.entryList({ base + "*" });
    for (auto e: entries) {
        if (e == library) continue;
        QString destination = targetDir + "/" + e;
        if (!backup(destination, backupDir)) {
            continue;
        }
        if (!unbundleFile(source + "/" + e, destination, false)) {
            continue;
        }
    }

    return {};
}

QString
getHelpText(vector<LibraryInfo> libraries)
{
    set<QString, function<bool (QString, QString)>>
        makers
        ([](QString k1, QString k2) {
             return k1.localeAwareCompare(k2) < 0;
         });

    for (auto info: libraries) {
        makers.insert(info.maker);
    }

    QString makerList;
    for (QString maker: makers) {
        makerList += QObject::tr("<li>%1</li>").arg(maker);
    }
    
    return QObject::tr
        ("<p>Vamp Plugin Pack collects together a number of <a href=\"https://vamp-plugins.org\">Vamp audio analysis plugins</a> into a single installer.</p>"
         "<p>The libraries you select will be installed into the standard Vamp plugin directory, where hosts such as <a href=\"https://sonicvisualiser.org/\">Sonic Visualiser</a> can find them.</p>"
         "<p>The plugin libraries included here were developed and published by various different authors and institutions:</p><ul>%1</ul>"
         "<p>All of the libraries are open source and are redistributable under open-source licences. Click the information icon to the right of each library in the main window for more details.</p>"
         "<p>The entire pack may be redistributed under the <a href=\"%2\">GNU Affero General Public License v3</a>.</p>"
         "<p>The plugins were collected together, and the installer was written and published, at the <a href=\"https://c4dm.eecs.qmul.ac.uk\">Centre for Digital Music</a>, Queen Mary University of London.</p>")
        .arg(makerList)
        .arg(getLicenceURL(Licence::agpl));
}

vector<LibraryInfo>
getUserApprovedPluginLibraries(vector<LibraryInfo> libraries,
                               QString targetDir)
{
    QDialog dialog;

    int fontHeight = QFontMetrics(dialog.font()).height();
    int dpratio = dialog.devicePixelRatio();

    auto mainLayout = new QGridLayout;
    mainLayout->setSpacing(0);
    dialog.setLayout(mainLayout);

    int mainRow = 0;
    
    auto selectionFrame = new QWidget;
    mainLayout->addWidget(selectionFrame, mainRow, 0);
    ++mainRow;
    
    auto selectionLayout = new QGridLayout;
    selectionLayout->setContentsMargins(0, 0, 0, 0);
    selectionLayout->setSpacing(fontHeight / 6);
    selectionFrame->setLayout(selectionLayout);

    int selectionRow = 0;
    int checkColumn = 0;
    int titleColumn = 1;
    int statusColumn = 2;
    int infoColumn = 4; // column 3 is a small sliver of spacing

    selectionLayout->addWidget
        (new QLabel(QObject::tr("<b>Vamp Plugin Pack</b> v%1")
                    .arg(PACK_VERSION)),
         selectionRow, titleColumn, 1, 3);
    ++selectionRow;

    selectionLayout->addWidget
        (new QLabel(QObject::tr("Select the plugin libraries to install:")),
         selectionRow, titleColumn, 1, 3);
    ++selectionRow;
    
    auto checkAll = new QCheckBox;
    checkAll->setChecked(true);
    selectionLayout->addWidget
        (checkAll, selectionRow, checkColumn, Qt::AlignHCenter);
    ++selectionRow;

    auto checkArrow = new QLabel(
#ifdef Q_OS_MAC
        "&nbsp;&nbsp;&#9660;"
#else
        "&#9660;"
#endif
        );
    checkArrow->setTextFormat(Qt::RichText);
    selectionLayout->addWidget
        (checkArrow, selectionRow, checkColumn, Qt::AlignHCenter);
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

    QPixmap infoMap(fontHeight * dpratio, fontHeight * dpratio);
    QPixmap moreMap(fontHeight * dpratio * 2, fontHeight * dpratio * 2);
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
        selectionLayout->addWidget
            (cb, selectionRow, checkColumn, Qt::AlignHCenter);

        LibraryInfo info = ip.second;

        auto shortLabel = new QLabel(info.title);
        selectionLayout->addWidget(shortLabel, selectionRow, titleColumn);

        RelativeStatus relativeStatus = getRelativeStatus(info, targetDir);
        auto statusLabel = new QLabel(relativeStatusLabel(relativeStatus));
        selectionLayout->addWidget(statusLabel, selectionRow, statusColumn);
        cb->setChecked(shouldCheck(relativeStatus));
        
        auto infoButton = new QToolButton;
        infoButton->setAutoRaise(true);
        infoButton->setIcon(infoMap);
        infoButton->setIconSize(QSize(fontHeight, fontHeight));

#ifdef Q_OS_MAC
        infoButton->setFixedSize(QSize(int(fontHeight * 1.2), 
                                   int(fontHeight * 1.2)));
        infoButton->setStyleSheet("QToolButton { border: none; }");
#endif

        selectionLayout->addWidget(infoButton, selectionRow, infoColumn);

        ++selectionRow;

        QString moreTitleText = QObject::tr("<b>%1</b><br><i>%2</i>")
            .arg(info.title)
            .arg(info.maker);

        QString moreInfoText = info.description;
        
        if (info.page != "") {
            moreInfoText += QObject::tr("<br><a href=\"%1\">%2</a>")
                .arg(info.page)
                .arg(info.page);
        }

        moreInfoText += QObject::tr("<br><br>Library contains:<ul>");

        int n = 0;
        bool closed = false;
        for (auto title: info.pluginTitles) {
            if (n == 10 && info.pluginTitles.size() > 15) {
                moreInfoText += QObject::tr("</ul>");
                moreInfoText += QObject::tr("... and %n other plugins.<br><br>",
                                            "",
                                            info.pluginTitles.size() - n);
                closed = true;
                break;
            }
            moreInfoText += QObject::tr("<li>%1</li>").arg(title);
            ++n;
        }

        if (!closed) {
            moreInfoText += QObject::tr("</ul>");
        }

        if (info.licence != "") {
            moreInfoText += QObject::tr("Provided under the <a href=\"%1\">%2</a>.<br>")
                .arg(getLicenceURL(info.licence))
                .arg(info.licence);
        }
        
        QObject::connect(infoButton, &QAbstractButton::clicked,
                         [=]() {
                             QMessageBox mbox;
                             mbox.setIconPixmap(moreMap);
                             mbox.setWindowTitle(QObject::tr("Library contents"));
                             mbox.setText(moreTitleText);
                             mbox.setInformativeText(moreInfoText);
                             mbox.exec();
                         });
        
        checkBoxMap[info.fileName] = cb;
        libFileInfo[info.fileName] = info;
        statuses[info.fileName] = relativeStatus;
    }

    selectionLayout->addItem(new QSpacerItem(1, (fontHeight*2) / 3),
                             selectionRow, 0);
    ++selectionRow;

    selectionLayout->addWidget
        (new QLabel(QObject::tr("Installation will be to: %1").arg(targetDir)),
         selectionRow, titleColumn, 1, 3);
    ++selectionRow; 

    QObject::connect(checkAll, &QCheckBox::toggled,
                     [=](bool toCheck) {
                         for (auto p: checkBoxMap) {
                             p.second->setChecked(toCheck);
                         }
                     });

    mainLayout->addItem(new QSpacerItem(1, fontHeight), mainRow, 0);
    ++mainRow;
    
    auto bb = new QDialogButtonBox(QDialogButtonBox::Ok |
                                   QDialogButtonBox::Cancel |
                                   QDialogButtonBox::Reset |
                                   QDialogButtonBox::Help);
    bb->button(QDialogButtonBox::Ok)->setText(QObject::tr("Install"));
    mainLayout->addWidget(bb, mainRow, 0);
    ++mainRow;

    mainLayout->setRowStretch(0, 10);
    mainLayout->setColumnStretch(0, 10);
    selectionLayout->setColumnMinimumWidth(0, 50);
#ifdef Q_OS_MAC
    selectionLayout->setColumnMinimumWidth(3, 10);
    selectionLayout->setColumnMinimumWidth(5, 12);
#endif
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

             case QDialogButtonBox::HelpRole: {
                 QMessageBox mbox;
                 mbox.setWindowTitle(QApplication::applicationName());
                 mbox.setText(QObject::tr("<b>Vamp Plugin Pack</b>"));
                 mbox.setInformativeText(getHelpText(libraries));
                 mbox.exec();
                 break;
             }
                 
             default:
                 SVCERR << "WARNING: Unexpected role " << role << endl;
                 break;
             }
         });

    if (QString(PACK_VERSION).contains("-pre") ||
        QString(PACK_VERSION).contains("-alpha") ||
        QString(PACK_VERSION).contains("-beta")) {
        QTimer::singleShot
            (500, [&]() {
                      QString url = "https://code.soundsoftware.ac.uk/projects/vamp-plugin-pack";
                      QMessageBox::information
                          (&dialog, QObject::tr("Test release"),
                           QObject::tr("<b>This is a test release of %1</b><p>Please send any feedback to the developers. See <a href=\"%2\">%3</a> for more information.</p>").arg(QApplication::applicationName()).arg(url).arg(url));
                  });
    }

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
    if (argc == 2 && (QString(argv[1]) == "--version" ||
                      QString(argv[1]) == "-v")) {
        cerr << PACK_VERSION << std::endl; // std:: needed here for MSVC for some reason
        exit(0);
    }
    
    QApplication app(argc, argv);

    QApplication::setOrganizationName("sonic-visualiser");
    QApplication::setOrganizationDomain("sonicvisualiser.org");
    QApplication::setApplicationName(QApplication::tr("Vamp Plugin Pack Installer"));

    QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

#ifdef Q_OS_WIN32
    QFont font(QApplication::font());
    QString preferredFamily = "Segoe UI";
    font.setFamily(preferredFamily);
    if (QFontInfo(font).family() == preferredFamily) {
        font.setPointSize(10);
        QApplication::setFont(font);
    }
#else
#ifdef Q_OS_MAC
    QFont font(QApplication::font());
    QString preferredFamily = "Lucida Grande";
    font.setFamily(preferredFamily);
    if (QFontInfo(font).family() == preferredFamily) {
        font.setPointSize(12);
        QApplication::setFont(font);
    }
#endif
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
    
    QProgressDialog progress(QObject::tr("Installing..."),
                             QObject::tr("Stop"), 0,
                             int(toInstall.size()) + 1);
    progress.setMinimumDuration(0);

    if (toInstall.empty()) { // Cancelled, or nothing selected
        SVCERR << "No libraries selected for installation, nothing to do"
               << endl;
        progress.hide();
        QMessageBox::information
            (&progress,
             QObject::tr("Nothing to do"),
             QObject::tr("No libraries selected for installation"),
             QMessageBox::Ok,
             QMessageBox::Ok);
        return 0;
    }
    
    int pval = 0;
    bool complete = true;
    
    for (auto lib: toInstall) {
        progress.setValue(++pval);
        QThread::currentThread()->msleep(40);
        app.processEvents();
        if (progress.wasCanceled()) {
            complete = false;
            break;
        }
        QString error = installLibrary(lib, target);
        if (error != "") {
            complete = false;
            if (QMessageBox::critical
                (&progress,
                 QObject::tr("Install failed"),
                 QObject::tr("Failed to install library \"%1\": %2")
                 .arg(lib.title)
                 .arg(error),
                 QMessageBox::Abort | QMessageBox::Ignore,
                 QMessageBox::Ignore) ==
                QMessageBox::Abort) {
                break;
            }
        }
    }

    progress.hide();

    if (complete) {
        QMessageBox::information
            (&progress,
             QObject::tr("Complete"),
             QObject::tr("Installation completed successfully"),
             QMessageBox::Ok,
             QMessageBox::Ok);
    } else {
        QMessageBox::information
            (&progress,
             QObject::tr("Incomplete"),
             QObject::tr("Installation was not complete. Exiting"),
             QMessageBox::Ok,
             QMessageBox::Ok);
    }
    
    return (complete ? 0 : 2);
}
