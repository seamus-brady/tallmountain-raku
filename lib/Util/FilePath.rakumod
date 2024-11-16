use v6.d;

class Util::FilePath {

    my constant $CONFIG_DIR = '/config';

    method app-root(-->Str){
        # get the root dir of the app
        return $?FILE.IO.parent(3).absolute;
    }

    method config-path(-->Str){
        return self.app-root ~ $CONFIG_DIR;
    }
}
