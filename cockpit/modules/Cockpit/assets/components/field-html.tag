<field-html>

    <textarea ref="input" class="uk-visibility-hidden" hidden></textarea>

    <script>

        var $this = this, editor, evtSrc;

        this.value = '';

        this._field = null;

        this.$updateValue = function(value, field) {

            if (this.value != value) {

                this.value = value;

                if (editor && !evtSrc) {
                    editor.editor.setValue(value || '', true);
                }
            }

            evtSrc = false;

        }.bind(this);


        this.on('mount', function(){

            codemirror().then(function() {

                App.assets.require([
                    '/assets/lib/marked.js',
                    '/assets/lib/uikit/js/components/htmleditor.js'
                ], function() {

                    $this.refs.input.value = $this.value;

                    editor = UIkit.htmleditor(this.refs.input, opts);

                    editor.editor.on('change', function() {
                        evtSrc = true;
                        $this.$setValue(editor.editor.getValue());
                    });

                    editor.addButtons({
                        cpfinder: {
                            title : 'Finder',
                            label : '<i class="uk-icon-folder-open"></i>'
                        },
                        cpasset: {
                            title : 'Asset',
                            label : '<i class="uk-icon-cloud"></i>'
                        }
                    });

                    editor.on('action.cpfinder', function() {
                        App.media.select(function(selected) {

                            if (editor.getCursorMode() == 'markdown') {
                                editor['replaceSelection']('[title]('+SITE_URL+'/'+selected[0]+')');
                            } else {
                                editor['replaceSelection']('<a src="'+SITE_URL+'/'+selected[0]+'">'+selected[0]+'</a>');
                            }

                        }, { });
                    });

                    editor.on('action.cpasset', function() {

                        App.assets.select(function(assets){

                            if (Array.isArray(assets) && assets.length) {

                                var asset = assets[0], isImage = asset.mime.match(/^image\//);

                                if (editor.getCursorMode() == 'markdown') {
                                    editor['replaceSelection'](isImage ? '!['+asset.title+']('+ASSETS_URL+asset.path+')' : '['+asset.title+']('+ASSETS_URL+asset.path+')');
                                } else {
                                    editor['replaceSelection'](isImage ? '<img src="'+ASSETS_URL+asset.path+'" alt="'+asset.title+'">' : '<a href="'+ASSETS_URL+asset.path+'">'+asset.title+'</a>');
                                }
                            }
                        });
                    });

                    editor.options.toolbar = editor.options.toolbar.concat(['cpfinder', 'cpasset']);

                    App.$(document).trigger('init-html-editor', [editor]);

                }.bind($this));

            });

        });

    </script>

</field-html>
