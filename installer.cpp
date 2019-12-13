
#include <QApplication>
#include <QString>
#include <QFile>
#include <QDir>

#include <iostream>
using namespace std;

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    QDir dir(":out/");
    auto entries = dir.entryList({ "*.so", "*.dll", "*.dylib" });

    for (auto e: entries) {
        cerr << e.toStdString() << endl;
    }

    QString target = QDir::homePath() + "/Library/Audio/Plug-Ins/Vamp/";

    for (auto e: entries) {
        QFile f(":out/" + e);
        if (!f.copy(target + e)) {
            cerr << "Failed to copy " << e.toStdString()
                 << " to target " << (target + e).toStdString() << endl;
	    continue;
        }
	if (!QFile::setPermissions(target + e, 
				   QFile::ReadOwner | QFile::WriteOwner | 
				   QFile::ExeOwner | QFile::ReadGroup | 
				   QFile::ReadOther)) {
            cerr << "Failed to set permissions on " << e.toStdString() << endl;
	    continue;
	}
    }
    
    return 0;
}
