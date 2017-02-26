package laldiscordbothx.model.commandlist;

import discordhx.channel.GroupDMChannel;
import discordhx.channel.DMChannel;
import discordbothx.core.DiscordBot;
import discordhx.Collection;
import discordhx.channel.ChannelType;
import discordhx.channel.Channel;
import discordbothx.core.CommunicationContext;
import discordhx.channel.TextChannel;
import discordhx.user.User;
import discordhx.message.Message;

class Avatar extends LALBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(username)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var channel: Channel = context.message.channel;
        var foundUser: User = null;

        if (context.message.mentions.users.size > 0) {
            foundUser = context.message.mentions.users.first();
        } else if (args.length > 0) {
            var userList: Collection<String, User> = new Collection<String, User>();

            if (channel.type == ChannelType.DM) {
                var directChannel: DMChannel = cast channel;

                userList.set(DiscordBot.instance.client.user.id, DiscordBot.instance.client.user);
                userList.set(directChannel.recipient.id, directChannel.recipient);
            } else {
                if (channel.type == ChannelType.GROUP) {
                    var groupChannel: GroupDMChannel = cast channel;

                    userList = groupChannel.recipients;
                } else {
                    var textChannel: TextChannel = cast channel;

                    for (member in textChannel.members.array()) {
                        userList.set(member.user.id, member.user);
                    }
                }
            }

            foundUser = userList.find(function (user: User): Bool {
                return user.username.toLowerCase().indexOf(args.join(' ').toLowerCase()) > -1;
            });
        } else {
            foundUser = author;
        }

        if (foundUser != null) {
            if (foundUser.id == DiscordBot.instance.client.user.id) {
                context.sendFileToChannel(foundUser.displayAvatarURL, foundUser.id + '.jpg', author.toString()).then(function (sentMessage: Message) {
                    context.sendToChannel(l('client_avatar_author', cast ['https://twitter.com/MiagoMeowsome']));
                });
            } else {
                context.sendFileToChannel(foundUser.displayAvatarURL, foundUser.id + '.jpg', author.toString());
            }
        } else {
            context.sendToChannel(l('not_found', cast [author]));
        }
    }
}
