
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

#include <iostream>
using namespace std;

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
getUserApprovedPluginLibraries(QStringList libraries)
{
    QDialog dialog;
    auto layout = new QVBoxLayout;

    std::map<QString, QCheckBox *> checkBoxMap;
    
    for (auto lib: libraries) {
        auto cb = new QCheckBox(lib);
        layout->addWidget(cb);
        checkBoxMap[lib] = cb;
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

    QStringList toInstall = getUserApprovedPluginLibraries(libraries);
    
    for (auto lib: toInstall) {
        installLibrary(lib, target);
    }
    
    return 0;
}
