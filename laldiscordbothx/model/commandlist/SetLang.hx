package laldiscordbothx.model.commandlist;

import laldiscordbothx.translations.Lang;
import discordbothx.core.CommunicationContext;
import laldiscordbothx.utils.DiscordUtils;
import laldiscordbothx.translations.LangCenter;

class SetLang extends LALBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(lang)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var lang: String = StringTools.trim(args[0]);
            var langList: Array<String> = cast [
                Lang.fr_FR,
                Lang.en_GB
            ];

            if (langList.indexOf(lang) > -1) {
                var serverId = DiscordUtils.getServerIdFromMessage(context.message);

                LangCenter.instance.setLang(serverId, cast lang);
                context.sendToChannel(l('answer', cast [author]));
            } else {
                context.sendToChannel(l('wrong_lang', cast [author]));
            }
        } else {
            context.sendToChannel(l('wrong_format', cast [author]));
        }
    }
}
