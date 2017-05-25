package laldiscordbothx.model.commandlist;

import discordbothx.log.Logger;
import discordbothx.core.CommunicationContext;
import StringTools;
import discordhx.message.Message;
import nodejs.http.HTTP.HTTPMethod;
import haxe.Json;
import laldiscordbothx.utils.HttpUtils;

class OED extends LALBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        nbRequiredParams = 1;
        paramsUsage = '(word)';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var domain = 'od-api.oxforddictionaries.com';
            var basePath = '/api/v1';
            var auth = new Map<String, String>();

            auth.set('app_id', Bot.instance.authDetails.OED_APP_ID);
            auth.set('app_key', Bot.instance.authDetails.OED_APP_KEY);

            HttpUtils.query(true, domain, basePath + '/search/en?limit=1&q=' + StringTools.urlEncode(args.join(' ')), cast HTTPMethod.Get, function (data: String) {
                var response: Dynamic = null;

                try {
                    response = Json.parse(data);
                } catch (err: Dynamic) {
                    Logger.exception(err);
                }

                if (response != null && Reflect.hasField(response, 'results')) {
                    if (response.results.length > 0) {
                        var word = response.results[0].word;

                        HttpUtils.query(true, domain, basePath + '/entries/en/' + StringTools.urlEncode(response.results[0].id), cast HTTPMethod.Get, function (data: String) {
                            var response: Dynamic = null;

                            try {
                                response = Json.parse(data);
                            } catch (err: Dynamic) {
                                Logger.exception(err);
                            }

                            var message = '**' + word + '**\n\n';
                            var lexicalEntries: Array<Dynamic> = cast response.results[0].lexicalEntries;

                            for (lexicalEntry in lexicalEntries) {
                                message += '**' + lexicalEntry.lexicalCategory.toUpperCase() + '**\n\n';

                                var entries: Array<Dynamic> = cast lexicalEntry.entries;

                                for (entry in entries) {
                                    if (Reflect.hasField(entry, 'senses')) {
                                        var sensesIndex = 1;
                                        var senses: Array<Dynamic> = cast entry.senses;

                                        for (sense in senses) {
                                            var definition: String = null;

                                            if (Reflect.hasField(sense, 'definitions')) {
                                                definition = sense.definitions[0].substr(0, 1).toUpperCase();
                                                definition += sense.definitions[0].substr(1);
                                            } else if (Reflect.hasField(sense, 'crossReferenceMarkers')) {
                                                definition = sense.crossReferenceMarkers[0].substr(0, 1).toUpperCase();
                                                definition += sense.crossReferenceMarkers[0].substr(1);
                                            }

                                            if (definition != null) {
                                                message += '**' + sensesIndex + '.** ' + definition + '\n';

                                                if (Reflect.hasField(sense, 'examples')) {
                                                    var examples: Array<Dynamic> = cast sense.examples;

                                                    for (example in examples) {
                                                        var exampleText = example.text.substr(0, 1).toUpperCase();

                                                        exampleText += example.text.substr(1);
                                                        message += '    *‘' + exampleText + '’*\n';
                                                    }
                                                }

                                                message += '\n';

                                                if (Reflect.hasField(sense, 'subsenses')) {
                                                    var subsenses: Array<Dynamic> = sense.subsenses;
                                                    var subsensesIndex = 1;

                                                    for (subsense in subsenses) {
                                                        if (Reflect.hasField(subsense, 'definitions')) {
                                                            var definition = subsense.definitions[0].substr(0, 1).toUpperCase();

                                                            definition += subsense.definitions[0].substr(1);

                                                            message += '    **' + sensesIndex + '.' + subsensesIndex + '.** ' + definition + '\n';

                                                            if (Reflect.hasField(subsense, 'examples')) {
                                                                var examples: Array<Dynamic> = cast subsense.examples;

                                                                for (example in examples) {
                                                                    var exampleText = example.text.substr(0, 1).toUpperCase();

                                                                    exampleText += example.text.substr(1);
                                                                    message += '        *‘' + exampleText + '’*\n';
                                                                }
                                                            }

                                                            message += '\n';

                                                            subsensesIndex++;
                                                        } else if (Reflect.hasField(subsense, 'crossReferenceMarkers')) {
                                                            var definition = subsense.crossReferenceMarkers[0].substr(0, 1).toUpperCase();

                                                            definition += subsense.crossReferenceMarkers[0].substr(1);
                                                            message += '    **' + sensesIndex + '.' + subsensesIndex + '.** ' + definition + '\n\n';

                                                            subsensesIndex++;
                                                        }
                                                    }
                                                }

                                                sensesIndex++;
                                            }
                                        }
                                    }
                                }
                            }

                            context.sendToChannel(message, cast {split: true});
                        }, null, auth);
                    } else {
                        context.sendToChannel(l('404', cast [author]));
                    }
                } else {
                    context.sendToChannel(l('fatal', cast [author]));
                }
            }, null, auth);
        } else {
            context.sendToChannel(l('fail', cast [author]));
        }
    }
}
