jivo_config = {
	/*
	 "plane_color":"red",

	 "agentMessage_bg_color":'green', //цвет агентского сообщения
	 "agentMessage_txt_color":'blue', //цвет текста агентского сообщения

	 "clientMessage_bg_color":'yellow', //цвет клиентского сообщения
	 "clientMessage_txt_color":'black', //цвет текста клиентского сообщения
	*/
	"plane_color":"#FFC107",
	"active_message": "Здравствуйте! Я могу вам чем-то помочь?",
	"widget_id": "lhjzK1ha9r", //widget_id
	"site_id": 431188, //site_id
	"app_link": "My_SevStar_App",//ссылка, которая будет светиться у оператора
	"placeholder": "Введите сообщение",
	"secure": true,
	"department_id": 24633
}




// __jivoConfigOnLoad(
// {
// 	"widget_id":"jWQigXS11b",
// 	"site_id":431188,
// 	"widget_color":"#FFC107",
// 	"widget_font_color":"dark",
// 	"widget_padding":"50",
// 	"widget_height":"33",
// 	"widget_orientation":"right",
// 	"widget_mobile_orientation":"left",
// 	"font_size":"14",
// 	"font_family":"Arial"
// 	,"font_type":"normal",
// 	"locale":"ru_RU",
// 	"show_rate_form":1,
// 	"hide_ad":1,
// 	"secure":1,
// 	"contacts_ask":0,
// 	"style_string":"jivo_shadow jivo_rounded_corners jivo_gradient jivo_3d_effect jivo_border jivo_3px_border jivo_dark_text",
// 	"chat_mode":1?"online":"offline",
// 	"geoip":"RU;48;Moscow",
// 	"botmode":false,
// 	"options":888,
// 	"hide_offline":1,
// 	"build_number":"1563798484",
// 	"avatar_url":"\/\/files.jivosite.com",
// 	"api_host":"api.jivosite.com",
// 	"tel_host":"telephony-main.jivosite.com",
// 	"online_widget_label":"\u041d\u0443\u0436\u043d\u0430 \u043f\u043e\u043c\u043e\u0449\u044c? \u041e\u0442\u0432\u0435\u0442\u0438\u043c \u043e\u043d\u043b\u0430\u0439\u043d",
// 	"offline_widget_label":"\u041e\u0442\u043f\u0440\u0430\u0432\u044c\u0442\u0435 \u043d\u0430\u043c \u0441\u043e\u043e\u0431\u0449\u0435\u043d\u0438\u0435",
// 	"offline_form_text":"\u041e\u0441\u0442\u0430\u0432\u044c\u0442\u0435 \u0441\u0432\u043e\u0435 \u0441\u043e\u043e\u0431\u0449\u0435\u043d\u0438\u0435 \u0432 \u044d\u0442\u043e\u0439 \u0444\u043e\u0440\u043c\u0435, \u0438 \u043c\u044b \u0438 \u043e\u0431\u044f\u0437\u0430\u0442\u0435\u043b\u044c\u043d\u043e \u043e\u0442\u0432\u0435\u0442\u0438\u043c!",
// 	"bubble_color":"grey",
// 	"callback_btn_color":"#44BB6E",
// 	"power_button_color":"#FFC107",
// 	"base_url":"\/\/code.jivosite.com",
// 	"static_host":"cdn.jivosite.com",
// 	"comet":{"host":"node128.jivosite.com"},
// 	"rules":[
// 		{"conditions":[{"condition":"online","value":true},{"condition":"time_on_page","comparator":"greater","value":10},{"condition":"time_on_site","comparator":"greater","value":20},{"condition":"time_after_close","comparator":"greater","value":300},{"condition":"time_after_invitation","comparator":"greater","value":60},{"condition":"page_url","comparator":"not_contain","value":"sevstar.net\/oko"},{"condition":"page_url","comparator":"not_contain","value":"my.sevstar.net"},{"condition":"page_url","comparator":"not_contain","value":"sevstar.net\/karta-sveta"}],"commands":[{"command":"proactive","params":{"message":"\u0417\u0434\u0440\u0430\u0432\u0441\u0442\u0432\u0443\u0439\u0442\u0435! \u042f \u043c\u043e\u0433\u0443 \u0432\u0430\u043c \u0447\u0435\u043c-\u0442\u043e \u043f\u043e\u043c\u043e\u0447\u044c?"}}],"name":"\u0410\u043a\u0442\u0438\u0432\u043d\u043e\u0435 \u043f\u0440\u0438\u0433\u043b\u0430\u0448\u0435\u043d\u0438\u0435 \u0432 \u0434\u0438\u0430\u043b\u043e\u0433","enabled":true,"type":"all"},{"name":"\u0421\u0431\u043e\u0440 \u043a\u043e\u043d\u0442\u0430\u043a\u0442\u043e\u0432 \u0432 \u0440\u0435\u0436\u0438\u043c\u0435 \u043e\u0444\u0444\u043b\u0430\u0439\u043d","enabled":true,"type":"all","conditions":[{"condition":"online","value":false},{"condition":"time_on_page","comparator":"greater","value":10},{"condition":"time_on_site","comparator":"greater","value":20},{"condition":"time_after_close","comparator":"greater","value":300},{"condition":"time_after_invitation","comparator":"greater","value":60}],"commands":[{"command":"open_offline","params":{"title":"\u041e\u0442\u043f\u0440\u0430\u0432\u044c\u0442\u0435 \u043d\u0430\u043c \u0441\u043e\u043e\u0431\u0449\u0435\u043d\u0438\u0435","message":"\u041e\u0441\u0442\u0430\u0432\u044c\u0442\u0435 \u0441\u0432\u043e\u0435 \u0441\u043e\u043e\u0431\u0449\u0435\u043d\u0438\u0435 \u0432 \u044d\u0442\u043e\u0439 \u0444\u043e\u0440\u043c\u0435, \u0438 \u043c\u044b \u043f\u043e\u043b\u0443\u0447\u0438\u043c \u0435\u0433\u043e \u043d\u0430 e-mail \u0438 \u043e\u0431\u044f\u0437\u0430\u0442\u0435\u043b\u044c\u043d\u043e \u043e\u0442\u0432\u0435\u0442\u0438\u043c!"}}]},{"name":"\u0423\u0434\u0435\u0440\u0436\u0438\u0432\u0430\u044e\u0449\u0430\u044f \u0444\u0440\u0430\u0437\u0430","enabled":true,"type":"all","conditions":[{"condition":"online","value":true},{"condition":"time_after_first_message","comparator":"greater","value":60}],"commands":[{"command":"system_message","params":{"message":"\u041f\u043e\u0436\u0430\u043b\u0443\u0439\u0441\u0442\u0430, \u043f\u043e\u0434\u043e\u0436\u0434\u0438\u0442\u0435. \u0421\u0435\u0439\u0447\u0430\u0441 \u043e\u043f\u0435\u0440\u0430\u0442\u043e\u0440\u044b \u0437\u0430\u043d\u044f\u0442\u044b, \u043d\u043e \u0441\u043a\u043e\u0440\u043e \u043a\u0442\u043e-\u043d\u0438\u0431\u0443\u0434\u044c \u043e\u0441\u0432\u043e\u0431\u043e\u0434\u0438\u0442\u0441\u044f \u0438 \u043e\u0442\u0432\u0435\u0442\u0438\u0442 \u0432\u0430\u043c!"}}]}
// 		],
// 	"typing_insight":1,
// 	"contacts_settings":{"name":{"show":true,"required":true},"email":{"show":true,"required":true},"phone":{"show":true,"required":false}},
// 	"webhooks_enabled":1,
// 	"departments":[
// 		{"id":"24632","name":"\u041e\u0442\u0434\u0435\u043b \u043f\u0440\u043e\u0434\u0430\u0436"},
// 		{"id":"24633","name":"\u041e\u0442\u0434\u0435\u043b \u0442\u0435\u0445\u043f\u043e\u0434\u0434\u0435\u0440\u0436\u043a\u0438"}
// 	],
// 	"new_visitors_insight":1,
// 	"vi_host":"chat4-2.jivosite.com",
// 	"joint":{"tg":{"botname":"SevStar_Bot"},"fb":{"app_id":"1614186198901622","joint_id":"299557070115713","link":"https:\/\/www.facebook.com\/sevstar.net\/"},"vb":{"botname":"sevstar"},"ya":"npzjgUfm6q","vk":{"app_id":"5299720","joint_id":"38875560"}},
// 	"power_button_phone":"+79788990000",
// 	"social_response":3,
// 	"api_domain":"https:\/\/erp.sevstar.net",
// 	"assigned_agent":1
// }
