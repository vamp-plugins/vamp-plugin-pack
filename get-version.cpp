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

#include <vamp-hostsdk/PluginHostAdapter.h>

// Undocumented internal API
#include <vamp-hostsdk/../src/vamp-hostsdk/Files.h>

#include <iostream>
#include <string>

using namespace std;

void usage(const char *me)
{
    cerr << endl;
    cerr << "Usage: " << me << " <soname>" << endl;
    cerr << endl;
    cerr << "Loads the Vamp plugin library found in <soname> and lists\n"
         << "the plugin versions found therein. Plugins are listed one per\n"
         << "line, with the plugin id and version number separated by a colon."
         << endl;
    cerr << endl;
    cerr << "Note that <soname> must be the path to a plugin library, not\n"
         << "merely the name of the library. That is, no search path is used.\n"
         << "The file path should be UTF-8 encoded (on all platforms)."
         << endl;
    cerr << endl;
    cerr << "The return code is 0 if the plugin library was successfully\n"
         << "loaded, otherwise 1. An error message may be printed to stderr\n"
         << "in the latter case." << endl;
    cerr << endl;
    exit(2);
}

int main(int argc, char **argv)
{
    char *scooter = argv[0];
    char *name = 0;
    while (scooter && *scooter) {
        if (*scooter == '/' || *scooter == '\\') name = ++scooter;
        else ++scooter;
    }
    if (!name || !*name) name = argv[0];
    
    if (argc != 2) usage(name);
    if (string(argv[1]) == string("-?")) usage(name);

    string libraryPath(argv[1]);
    
    void *handle = Files::loadLibrary(libraryPath);
    if (!handle) {
        cerr << "Unable to load library " << libraryPath << endl;
        return 1;
    }

    VampGetPluginDescriptorFunction fn =
        (VampGetPluginDescriptorFunction)Files::lookupInLibrary
        (handle, "vampGetPluginDescriptor");

    if (!fn) {
        cerr << "No vampGetPluginDescriptor function found in library \""
             << libraryPath << "\"" << endl;
        Files::unloadLibrary(handle);
        return 1;
    }

    int index = 0;
    const VampPluginDescriptor *descriptor = 0;

    while ((descriptor = fn(VAMP_API_VERSION, index))) {
        cout << descriptor->identifier << ":"
             << descriptor->pluginVersion << endl;
        ++index;
    }

    Files::unloadLibrary(handle);
    
    return 0;
}
