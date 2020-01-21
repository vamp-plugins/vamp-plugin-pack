
#include <QApplication>
#include <QString>
#include <QFile>
#include <QDir>

#include <QDialog>
#include <QFrame>
#include <QVBoxLayout>
#include <QCheckBox>
#include <QDialogButtonBox>

#include <vamp-hostsdk/PluginHostAdapter.h>

#include <dataquay/BasicStore.h>
#include <dataquay/RDFException.h>

#include <iostream>
#include <set>

using namespace std;
using namespace Dataquay;

QString
getDefaultInstallDirectory()
{
    auto pathList = Vamp::PluginHostAdapter::getPluginPath();
    if (pathList.empty()) {
        cerr << "Failed to look up Vamp plugin path" << endl;
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
        cerr << e.toStdString() << endl;
    }

    return entries;
}

unique_ptr<BasicStore>
loadLibrariesRdf()
{
    QDir dir(":out/");
    auto entries = dir.entryList({ "*.ttl", "*.n3" });

    unique_ptr<BasicStore> store(new BasicStore);

    for (auto e: entries) {

        QFile f(":out/" + e);
        if (!f.open(QFile::ReadOnly | QFile::Text)) {
            cerr << "Failed to open RDF resource file "
                 << e.toStdString() << endl;
            continue;
        }

        QByteArray content = f.readAll();
        f.close();

        try {
            store->importString(QString::fromUtf8(content), 
                                Uri("file:" + e),
                                BasicStore::ImportIgnoreDuplicates);
        } catch (const RDFException &ex) {
            cerr << "Failed to import RDF resource file "
                 << e.toStdString() << ": " << ex.what() << endl;
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
        
        LibraryInfo info;
        info.id = wi->first;
        info.fileName = wi->second;
        
        Node title = store.complete(Triple(t.subject(),
                                           store.expand("dc:title"),
                                           Node()));
        if (title.type == Node::Literal) {
            info.title = title.value;
        } else {
            info.title = info.id;
        }
        
        Node maker = store.complete(Triple(t.subject(),
                                           store.expand("foaf:maker"),
                                           Node()));
        if (maker.type == Node::Literal) {
            info.maker = maker.value;
        }

        Node desc = store.complete(Triple(t.subject(),
                                          store.expand("dc:description"),
                                          Node()));
        if (desc.type == Node::Literal) {
            info.description = desc.value;
        }

        results.push_back(info);
    }

    return results;
}

void
installLibrary(QString library, QString target)
{
    QFile f(":out/" + library);
    QString destination = target + "/" + library;
    cerr << "Copying " << library.toStdString() << " to "
         << destination.toStdString() << "..." << endl;
    if (!f.copy(destination)) {
        cerr << "Failed to copy " << library.toStdString()
             << " to target " << destination.toStdString() << endl;
        return;
    }
    if (!QFile::setPermissions
        (destination,
         QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner |
         QFile::ReadGroup | QFile::ExeGroup |
         QFile::ReadOther | QFile::ExeOther)) {
        cerr << "Failed to set permissions on "
             << library.toStdString() << endl;
        return;
    }
}

QStringList
getUserApprovedPluginLibraries(vector<LibraryInfo> libraries)
{
    QDialog dialog;
    auto layout = new QVBoxLayout;

    map<QString, QCheckBox *> checkBoxMap;

    map<QString, LibraryInfo> orderedInfo;
    for (auto info: libraries) {
        orderedInfo[info.title] = info;
    }
    
    for (auto ip: orderedInfo) {
        LibraryInfo info = ip.second;
        auto cb = new QCheckBox(info.title);
        layout->addWidget(cb);
        checkBoxMap[info.fileName] = cb;
    }

    auto bb = new QDialogButtonBox(QDialogButtonBox::Ok |
                                   QDialogButtonBox::Cancel);
    layout->addWidget(bb);
    QObject::connect(bb, SIGNAL(accepted()), &dialog, SLOT(accept()));
    QObject::connect(bb, SIGNAL(rejected()), &dialog, SLOT(reject()));

    dialog.setLayout(layout);
    
    if (dialog.exec() == QDialog::Accepted) {
        cerr << "accepted" << endl;
    } else {
        cerr << "rejected" << endl;
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
