use v6.d;

class DotEnv {

    method load_env_file() {
        my %env;

        if '.env'.IO.e {
            for '.env'.IO.lines -> $line {
                next if $line.trim eq "" || $line.trim.starts-with('#');  # Skip empty lines and comments

                if $line ~~ /^(.*?) '=' (.*)$/ {
                    my ($key, $value) = $0.trim, $1.trim;
                    %env{$key} = $value;
                }
                else {
                    warn "Skipping malformed line: '$line'";
                }
            }
        }
        return %env;
    }

    method dotenv_values(){

        my %env;

        if '.env'.IO.e {
            for '.env'.IO.lines -> $line {
                next if $line.trim eq "" || $line.trim.starts-with('#');  # Skip empty lines and comments

                if $line ~~ /^(.*?) '=' (.*)$/ {
                    my ($key, $value) = $0.trim, $1.trim;
                    %env{$key} = $value;
                }
                else {
                    warn "Skipping malformed line: '$line'";
                }
            }
        }

        return %env;
    }
}
