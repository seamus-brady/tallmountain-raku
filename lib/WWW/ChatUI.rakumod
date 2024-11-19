use v6.d;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Util::Config;

class WWW::ChatUI {
    # set up a simple web based UI

    has $.LOGGER = Util::Logger.new(namespace => "<WWW::ChatUI>");

    has Supplier $.chat-request-supplier = Supplier.new;
    has Supply $.chat-request-supply = $!chat-request-supplier.Supply;
    has Channel $.chat-response-channel = Channel.new;

    # set up the app routes for the chat UI
    has $.chat-ui-app = route {
        # process the user message and return the response
        post -> 'chat' {

            # get the user message from the request body
            my $prompt;
            request-body -> %fields {
                $prompt = %fields<message>;
            }
            self.LOGGER.debug("Received user message: '$prompt'");
            self.chat-request-supplier.emit($prompt);

            # get the bot reply
            my $bot-response = $!chat-response-channel.receive;
            self.LOGGER.debug("Received bot reply: '$bot-response'");

            # return the response as an htmx fragment
            my $htmx-fragment = self.get_response($prompt, $bot-response);
            content 'text/html', $htmx-fragment;
        }

        # serve the chat UI
        get -> {
            static 'www/chat_ui.html';
        }
    }

    method start-chat-ui() {
        self.LOGGER.debug("Chat UI starting...");
        my $host = Util::Config.get_config('chat_ui', 'chat_ui_server');
        my $port = Util::Config.get_config('chat_ui', 'chat_ui_port');

        # Start the chat ui server in the background
        start {
            my $server = Cro::HTTP::Server.new: host => $host, port => $port, application => $.chat-ui-app;
            $server.start;
            self.LOGGER.debug("TallMountain Chat UI available at http:://$host:$port");
            say "TallMountain Chat UI available at http:://$host:$port";
            react {
                whenever signal(SIGINT) {
                    self.LOGGER.debug("Shutting down TallMountain Chat UI...");
                    $.chat-request-supplier.done;
                    $server.stop;
                    done;
                }
            }
        }
    }

    method get_response(Str $prompt, Str $bot-response --> Str){
        my Str $response =  qq:to/END/;
            <div class="message-container user-message-container">
            <img src="https://img.icons8.com/color/48/000000/user.png" class="icon" alt="User Icon">
            <span>{$prompt}</span>
            </div>
            <div class="message-container bot-message-container">
            <img src="https://img.icons8.com/ios-filled/50/4a90e2/mountain.png" class="icon" alt="Bot Icon">
            <span class="bot-message">{$bot-response}</span>
            </div>
            END
        return $response.trim;
    }
}
