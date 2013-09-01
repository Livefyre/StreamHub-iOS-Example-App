# This file is NOT licensed under the GPLv3, which is the license for the rest
# of YouCompleteMe.
#
# Here's the license text for this file:
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

import os
import ycm_core
import ConfigParser
from clang_helpers import PrepareClangFlags

# These are the compilation flags that will be used in case there's no
# compilation database set (by default, one is not set).
# CHANGE THIS LIST OF FLAGS. YES, THIS IS THE DROID YOU HAVE BEEN LOOKING FOR.

flags = [
'-x',
'objective-c',
'-std=gnu99',
'-arch',
'i386',
'-g',
'-Os',
'-fmessage-length=0',
'-fobjc-arc',
'-fpascal-strings',
'-fexceptions',
'-fasm-blocks',
'-fstrict-aliasing',
'-fvisibility=hidden',
'-fdiagnostics-show-note-include-stack'
'-fmacro-backtrace-limit=0'
'-fobjc-abi-version=2',
'-fobjc-legacy-dispatch',
'-Wno-trigraphs',
'-Wno-missing-field-initializers',
'-Wno-missing-prototypes',
'-Wreturn-type',
'-Wno-implicit-atomic-properties',
'-Wno-receiver-is-weak',
'-Wduplicate-method-match',
'-Wformat',
'-Wno-missing-braces',
'-Wparentheses',
'-Wswitch',
'-Wno-unused-function',
'-Wno-unused-label',
'-Wno-unused-parameter',
'-Wunused-variable',
'-Wunused-value',
'-Wempty-body',
'-Wuninitialized',
'-Wno-unknown-pragmas',
'-Wno-shadow',
'-Wno-four-char-constants',
'-Wno-conversion',
'-Wno-constant-conversion',
'-Wno-bool-conversion',
'-Wno-int-conversion',
'-Wno-enum-conversion',
'-Wno-sign-conversion',
'-Wno-shorten-64-to-32',
'-Wpointer-sign',
'-Wno-newline-eof',
'-Wno-selector',
'-Wno-strict-selector-match',
'-Wno-undeclared-selector',
'-Wno-deprecated-implementations',
'-Wno-arc-repeated-use-of-weak',
'-Wprotocol',
'-Wdeprecated-declarations',
'-DCOCOAPODS=1',
'-isysroot',
'/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.0.sdk',
'-mios-simulator-version-min=6.0',
'-iquote',
'build/{target}.build/Release-iphonesimulator/{target}.build/{target}-generated-files.hmap',
'-Ibuild/{target}.build/Release-iphonesimulator/{target}.build/{target}-own-target-headers.hmap',
'-Ibuild/{target}.build/Release-iphonesimulator/{target}.build/{target}-all-target-headers.hmap',
'-iquote',
'build/{target}.build/Release-iphonesimulator/{target}.build/{target}-project-headers.hmap',
'-Ibuild/Release-iphonesimulator/include',
'-Ibuild/UninstalledProducts/include',
'-Ibuild/Release-iphonesimulator/usr/local/lib/include',
'-IPods/Headers',
'-Ibuild/{target}.build/Release-iphonesimulator/{target}.build/DerivedSources/i386',
'-Ibuild/{target}.build/Release-iphonesimulator/{target}.build/DerivedSources',
'-I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.0.sdk/usr/include',
#'-I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.0.sdk/usr/include',
#'-I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.0.sdk/System/Library/Frameworks/Foundation.framework/Headers',
#'-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',
'-Fbuild/Release-iphonesimulator',
'-DNS_BLOCK_ASSERTIONS=1',
'-MMD',
'-MT',
'-MF'
]

# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if compilation_database_folder:
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None


def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return flags

  config = ConfigParser.ConfigParser()
  config.read(os.path.join(working_directory, '.ycm_extra_conf.cfg'))
  options = dict(config.items('Path Variables'))

  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-F', '-iquote' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag.format(**options) )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path.format(**options) )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags


def FlagsForFile( filename ):
  if database:
    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object
    compilation_info = database.GetCompilationInfoForFile( filename )
    final_flags = PrepareClangFlags(
        MakeRelativePathsInFlagsAbsolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_ ),
        filename )

    # NOTE: This is just for YouCompleteMe; it's highly likely that your project
    # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
    # ycm_extra_conf IF YOU'RE NOT 100% YOU NEED IT.
    try:
      final_flags.remove( '-stdlib=libc++' )
    except ValueError:
      pass
  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )

  return {
    'flags': final_flags,
    'do_cache': True
  }
