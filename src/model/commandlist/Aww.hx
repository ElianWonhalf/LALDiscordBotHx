package model.commandlist;

import haxe.Json;
import StringTools;
import utils.ArrayUtils;
import utils.DiscordUtils;
import nodejs.http.HTTP.HTTPMethod;
import utils.Logger;
import utils.HttpUtils;
import translations.LangCenter;

class Aww implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.aww.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var bestArray: Array<String> = new Array<String>();
        var path = '/r/aww/new.json?count=100';

        bestArray.push('best');
        bestArray.push('top');
        bestArray.push('better');
        bestArray.push('hot');

        if (args.length > 0 && bestArray.indexOf(StringTools.trim(args[0])) > -1) {
            path = '/r/aww/.json?count=100';
        }

        HttpUtils.query(true, 'www.reddit.com', path, cast HTTPMethod.Get, function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'data') && Reflect.hasField(Reflect.field(response, 'data'), 'children')) {
                var children: Array<Dynamic> = response.data.children;

                children = children.filter(function (e: Dynamic): Bool {
                    var data = Reflect.field(e, 'data');
                    var hasPreview = Reflect.hasField(data, 'preview');
                    var hasImages = hasPreview && Reflect.hasField(Reflect.field(data, 'preview'), 'images');

                    return hasImages;
                });

                var picture = ArrayUtils.random(children);
                var serverId = DiscordUtils.getServerIdFromMessage(_context.getMessage());
                var message = author + ' => ' + ~/&amp;/g.replace(picture.data.url, '&') + '\n\n';

                message += LangCenter.instance.translate(serverId, 'model.commandlist.aww.process.topic_link');
                message += ' <https://www.reddit.com' + picture.data.permalink + '>';

                _context.rawSendToChannel(message);
            } else {
                Logger.error('Failed to load a cat picture');
                _context.sendToChannel('model.commandlist.aww.process.fail', cast [author]);
            }
        });
    }
}
