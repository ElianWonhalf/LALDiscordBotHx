package laldiscordbothx.model.commandlist;

import discordbothx.service.DiscordUtils;
import discordbothx.core.CommunicationContext;
import discordhx.message.Message;
import discordhx.channel.TextChannel;
import discordhx.role.Role;

class Rolelist extends LALBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (context.message.guild != null) {
            var channel:TextChannel = cast context.message.channel;
            var roles = channel.guild.roles.array();
            var message = l('answer') + '\n\n';
            var roleNames: Array<String> = roles.map(function (role: Role): String {
                return role.name;
            });

            roleNames.sort(function (a:String, b:String): Int {
                var ret = 0;

                if (a < b) {
                    ret = -1;
                } else if (a > b) {
                    ret = 1;
                }

                return ret;
            });

            for (role in roleNames) {
                var currentRole:String = role.toLowerCase();
                var roleIsRelay = currentRole == 'relay';
                var roleIsNative = currentRole.indexOf('native') == 0;
                var roleIsFluent = currentRole.indexOf('fluent') == 0;
                var roleIsLearning = currentRole.indexOf('learning') == 0;
                var roleIsStudying = currentRole.indexOf('studying') == 0;

                if (roleIsRelay || roleIsNative || roleIsFluent || roleIsLearning || roleIsStudying) {
                    message += role + '\n';
                }
            }

            context.sendToAuthor(message, cast {split: true}).then(function (message: Message) {
                context.sendToChannel(l('witness', cast [author]));
            });
        } else {
            context.sendToChannel(l('wrong_channel', cast [author]));
        }
    }
}