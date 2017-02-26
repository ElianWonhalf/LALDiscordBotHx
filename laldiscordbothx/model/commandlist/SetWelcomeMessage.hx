package laldiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import laldiscordbothx.model.entity.WelcomeMessage;
import laldiscordbothx.utils.DiscordUtils;
import StringTools;

class SetWelcomeMessage extends LALBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(message)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var message: String = StringTools.trim(args.join(' '));
            var idServer: String = DiscordUtils.getServerIdFromMessage(context.message);
            var welcomeMessage: WelcomeMessage = new WelcomeMessage();
            var uniqueValues: Map<String, String> = new Map<String, String>();

            uniqueValues.set('idServer', idServer);

            welcomeMessage.retrieve(uniqueValues, function (found: Bool): Void {
                if (!found) {
                    welcomeMessage.idServer = idServer;
                }

                welcomeMessage.message = message;

                welcomeMessage.save(function (err: Dynamic) {
                    if (err != null) {
                        context.sendToChannel(l('fail', cast [author, err]));
                    } else {
                        context.sendToChannel(l('success', cast [author]));
                    }
                });
            });
        } else {
            context.sendToChannel(l('wrong_format', cast [author]));
        }
    }
}
