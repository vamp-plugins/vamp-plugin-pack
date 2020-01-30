
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

#include <vamp-hostsdk/PluginHostAdapter.h>

#include <dataquay/BasicStore.h>
#include <dataquay/RDFException.h>

#include <iostream>
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

    std::map<QString, QString> wanted; // basename -> full lib name
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

void
installLibrary(QString library, QString target)
{
    QFile f(":out/" + library);
    QString destination = target + "/" + library;
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
}

QStringList
getUserApprovedPluginLibraries(vector<LibraryInfo> libraries)
{
    QDialog dialog;

    auto mainLayout = new QGridLayout;
    mainLayout->setSpacing(0);
    dialog.setLayout(mainLayout);

    int mainRow = 0;
    
    //!!! at top: title and check/uncheck all button
    
    auto checkAll = new QCheckBox;
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

    map<QString, QCheckBox *> checkBoxMap;

    map<QString, LibraryInfo, std::function<bool (QString, QString)>>
        orderedInfo
        ([](QString k1, QString k2) {
             return k1.localeAwareCompare(k2) < 0;
         });
    for (auto info: libraries) {
        orderedInfo[info.title] = info;
    }
    
    for (auto ip: orderedInfo) {

        auto cb = new QCheckBox;
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

    QObject::connect(bb, SIGNAL(accepted()), &dialog, SLOT(accept()));
    QObject::connect(bb, SIGNAL(rejected()), &dialog, SLOT(reject()));

    if (dialog.exec() == QDialog::Accepted) {
        SVCERR << "accepted" << endl;
    } else {
        SVCERR << "rejected" << endl;
    }

    QStringList approved;
    for (const auto &p: checkBoxMap) {
        if (p.second->isChecked()) {
            approved.push_back(p.first);
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
    
    QStringList toInstall = getUserApprovedPluginLibraries(info);
    
    for (auto lib: toInstall) {
        installLibrary(lib, target);
    }
    
    return 0;
}
