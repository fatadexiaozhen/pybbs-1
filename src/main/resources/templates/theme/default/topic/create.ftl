<#include "../layout/layout.ftl"/>
<@html page_title="创建话题" page_tab="">
    <!-- 插件引入 -->
    <link href="http://cdnjs.cloudflare.com/ajax/libs/summernote/0.8.9/summernote.css" rel="stylesheet">
    <script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.js"></script>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/summernote/0.8.9/summernote.js"></script>
    <!--引入中文JS包-->
    <script src="https://cdn.bootcss.com/summernote/0.8.10/lang/summernote-zh-CN.js"></script>  //因为这个插件是国外的写的，一定要引入这个中文包，不然编辑器是默认的英文


    <div class="row">
        <div class="col-md-9">
            <div class="card">
                <div class="card-header">发布话题</div>
                <div class="card-body">
                    <form action="" onsubmit="return;" id="form">
                        <div class="form-group">
                            <label for="title">标题</label>
                            <input type="text" name="title" id="title" class="form-control" placeholder="标题"/>
                        </div>
                        <div class="form-group">
                            <label for="content">内容</label>
                            <span class="pull-right">
                            <a href="javascript:uploadFile('topic')">上传图片</a>&nbsp;
                            <a href="javascript:uploadFile('video')">上传视频</a>
                          </span>
                            <textarea name="content" id="content" class="form-control"
                                      placeholder="内容，支持Markdown语法"></textarea>
<#--                            <div id="summernote" name="content2" placeholder="This is a test!" class="form-control"></div>-->
                        </div>
                        <div id="summernote" name="content2" placeholder="This is a test!" class="form-control"></div>
                        <#--<div class="form-group">
                          <label for="tags">标签</label>
                          <input type="text" name="tags" id="tags" value="${tag!}" class="form-control"
                                 placeholder="标签, 多个标签以 英文逗号 隔开"/>
                        </div>-->
                        <input type="hidden" name="tag" id="tag" value="${tag!}"/>
                        <div class="form-group">
                            <button type="button" id="btn" class="btn btn-info">发布话题</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <div class="col-md-3 hidden-xs">
            <#include "../components/markdown_guide.ftl"/>
            <#include "../components/create_topic_guide.ftl"/>
        </div>
    </div>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.47.0/codemirror.min.css" rel="stylesheet">
    <script src="/static/theme/default/js/codemirror.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.47.0/mode/markdown/markdown.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.47.0/addon/display/placeholder.min.js"></script>
    <script>
        $(function () {
            CodeMirror.keyMap.default["Shift-Tab"] = "indentLess";
            CodeMirror.keyMap.default["Tab"] = "indentMore";
            window.editor = CodeMirror.fromTextArea(document.getElementById("content"), {
                lineNumbers: true,     // 显示行数
                indentUnit: 4,         // 缩进单位为4
                tabSize: 4,
                matchBrackets: true,   // 括号匹配
                mode: 'markdown',     // Markdown模式
                lineWrapping: true,    // 自动换行
            });
            window.editor.setSize('auto', '450px');
//        编辑器功能=====================================
            $("#summernote").summernote({
                lang : 'zh-CN',// 语言
                height : 496, // 高度
                minHeight : 300, // 最小高度
                placeholder : '请输入文章内容', // 提示
                // summernote自定义配置
                toolbar: [
                    ['operate', ['undo','redo']],
                    ['magic',['style']],
                    ['style', ['bold', 'italic', 'underline', 'clear']],
                    ['para', ['height','fontsize','ul', 'ol', 'paragraph']],
                    ['font', ['strikethrough', 'superscript', 'subscript']],
                    ['color', ['color']],
                    ['insert',['picture','video','link','table','hr']],
                    ['layout',['fullscreen','codeview']],
                ],
                callbacks : { // 回调函数
                    // 上传图片时使用的回调函数   因为我们input选择的本地图片是二进制图片，需要把二进制图片上传服务器，服务器再返回图片url，就需要用到callback这个回调函数
                    onImageUpload : function(files) {
                        var form=new FormData();
                        form.append('file',files[0]); //myFileName 是上传的参数名，一定不能写错
                        form.append("type", "topic");
                        form.append("token", "${_user.token}");
                        $.ajax({
                            type:"post",
                            url:"/api/upload", //上传服务器地址
                            headers: {
                                'token': '${_user.token}'
                            },
                            dataType:'json',
                            data:form,
                            processData : false,
                            contentType : false,
                            cache : false,
                            xhr: function () { //获取ajaxSettings中的xhr对象，为它的upload属性绑定progress事件的处理函数
                                var myXhr = $.ajaxSettings.xhr();
                                if (myXhr.upload) { //检查upload属性是否存在
                                    //绑定progress事件的回调函数
                                    myXhr.upload.addEventListener('progress', progressHandlingFunction, false);
                                }
                                return myXhr; //xhr对象返回给jQuery使用
                            },
                            success:function(data){
                                if (data.code === 200) {
                                    if (data.detail.errors.length === 0) {
                                        suc("上传成功");
                                    } else {
                                        var error = "";
                                        for (var k = 0; k < data.detail.errors.length; k++) {
                                            error += data.detail.errors[k] + "<br/>";
                                        }
                                        err(error);
                                    }
                                    console.log(data.detail.urls);
                                    console.log(1);
                                    for (var j = 0; j < data.detail.urls.length; j++) {
                                        var url = data.detail.urls[j];
                                        console.log(url);
                                        $('#summernote').summernote('editor.insertImage',url);
                                    }
                                    console.log(2);
                                } else {
                                    err(data.description);
                                }

                            }
                        })
                    }
                }
            });
            $("#btn").click(function () {
                var title = $("#title").val();
                var tag = $("#tag").val();
                var content = window.editor.getDoc().getValue();
                // var tags = $("#tags").val();
                if (!title || title.length > 120) {
                    err("请输入标题，且最大长度在120个字符以内");
                    return;
                }
                // if (!tags || tags.split(",").length > 5) {
                //   err("请输入标签，且最多只能填5个");
                //   return;
                // }
                var _this = this;
                $(_this).button("loading");
                $.ajax({
                    url: '/api/topic',
                    cache: false,
                    async: false,
                    type: 'post',
                    dataType: 'json',
                    contentType: 'application/json',
                    headers: {
                        'token': '${_user.token}'
                    },
                    data: JSON.stringify({
                        title: title,
                        content: content,
                        tag: tag,
                        // tags: tags,
                    }),
                    success: function (data) {
                        if (data.code === 200) {
                            suc("创建成功");
                            setTimeout(function () {
                                window.location.href = "/topic/" + data.detail.id
                            }, 700);
                        } else {
                            err(data.description);
                            $(_this).button("reset");
                        }
                    }
                })
            });
        });
    </script>
    <#include "../components/upload.ftl"/>
</@html>
