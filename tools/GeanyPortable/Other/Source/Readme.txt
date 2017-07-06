Geany Portable Launcher
========================
Copyright 2004-2008 John T. Haller
Copyright 2007-2008 Patrick Patience
Copyright 2007-2009 Oliver Krystal

Website: http://PortableApps.com/GeanyPortable

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


About Geany Portable
====================
The Geany Portable Launcher allows you to run Geany from a removable drive whose
letter changes as you move it to another computer. The program can be entirely
self-contained on the drive and then used on any Windows computer.


License
=======
This code is released under the GPL.  The full code is included with this
package as GeanyPortable.nsi.


Installation / Directory Structure
==================================
By default, the program expects this directory structure:

-\ <--- Directory with GeanyPortable.exe
	+\App\
		+\Geany\
	+\Data\
		+\settings\
		+\fonts\ (optional)


It can be used in other directory configurations by including the AppNamePortable.ini file in the
same directory as GeanyPortable.exe and configuring it as details in the INI file section below.


GeanyPortable.ini Configuration
===============================
The Geany Portable Launcher will look for an ini file called GeanyPortable.ini within its
directory.  If you are happy with the default options, it is not necessary, though.  The INI
file is formatted as follows:

[GeanyPortable]
AdditionalParameters=
DisableSplashScreen=false
ApplicationLanguage=
AdditionalFonts=false
PathAdditions=

The AdditionalParameters entry allows you to pass additional commandline parameter entries
to Geany.exe.  Whatever you enter here will be appended to the call to Geany.exe.

The DisableSplashScreen entry allows you to disable the splash screen by setting it to
true (lowercase).

The ApplicationLanguage entry allows you to specify for a language that Geany will start in.  This will over ride the menu settings.

The AdditionalFonts entry allows you to specify if you would like Geany Portable to load extra fonts located in Data\fonts.  For more information
see PortableFontby wraithdu -> http://portableapps.com/node/16003.  Set it to true if you wish the GeanyPortable launcher to load custom fonts
for use in Geany.

The PathAdditions entry  allows you to specify from the root of the portable device locations to add to the path of Geany.  Use @Drive for the 
drive letter.  Specify in the format @Drive\Perl\bin\perl.exe, etc.  Seperate with a semicolon ;)

Program History / About the Authors
===================================
This launcher contains elements from multiple sources.  It is loosely based on the
Firefox Portable launcher and contains some ideas from mai9 and tracon on the mozillaZine
forums.
