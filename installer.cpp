
#include <QApplication>
#include <QString>
#include <QFile>
#include <QDir>

#include <vamp-hostsdk/PluginHostAdapter.h>

#include <iostream>
using namespace std;

int main(int argc, char **argv)
{
    auto pathList = Vamp::PluginHostAdapter::getPluginPath();
    if (pathList.empty()) {
        cerr << "Failed to look up Vamp plugin path" << endl;
        return 1;
    }

    QApplication app(argc, argv);
    QDir dir(":out/");
    auto entries = dir.entryList({ "*.so", "*.dll", "*.dylib" });

    for (auto e: entries) {
        cerr << e.toStdString() << endl;
    }

    auto firstPath = *pathList.begin();
    QString target = QString::fromUtf8(firstPath.c_str(), firstPath.size());

    for (auto e: entries) {
        QFile f(":out/" + e);
        QString destination = target + "/" + e;
        cerr << "Copying " << e.toStdString() << " to "
             << destination.toStdString() << "..." << endl;
        if (!f.copy(destination)) {
            cerr << "Failed to copy " << e.toStdString()
                 << " to target " << destination.toStdString() << endl;
	    continue;
        }
	if (!QFile::setPermissions
            (destination,
             QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner |
             QFile::ReadGroup | QFile::ExeGroup |
             QFile::ReadOther | QFile::ExeOther)) {
            cerr << "Failed to set permissions on " << e.toStdString() << endl;
	    continue;
	}
    }
    
    return 0;
}
