#Область ДополнительныеОбработки

Функция СведенияОВнешнейОбработке() Экспорт
	
	МассивНазначений = Новый Массив;
	
	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", "ДополнительнаяОбработка");
	ПараметрыРегистрации.Вставить("Назначение", МассивНазначений);
	ПараметрыРегистрации.Вставить("Наименование", "Отправка сообщений через email");
	ПараметрыРегистрации.Вставить("Версия", "2020.05.11");
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Ложь);
	ПараметрыРегистрации.Вставить("Информация", ИнформацияПоИсторииИзменений());
	ПараметрыРегистрации.Вставить("ВерсияБСП", "1.2.1.4");
	ТаблицаКоманд = ПолучитьТаблицуКоманд();
	ДобавитьКоманду(ТаблицаКоманд,
	                "Настройка отправки сообщений через email",
					"ОтправкаСообщенийAPI_email",
					"ОткрытиеФормы",
					Истина,
					);
	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Функция ПолучитьТаблицуКоманд()
	
	Команды = Новый ТаблицаЗначений;
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
	
	Возврат Команды;
	
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование, ПоказыватьОповещение = Ложь, Модификатор = "")
	
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
	
КонецПроцедуры

Функция ИнформацияПоИсторииИзменений()
	Возврат "
	| <div style='text-indent: 25px;'>Данная обработка позволяет отправлять сообщения через электронную почту.</div>
	| <hr />
	| Подробную информацию смотрите по адресу интернет: <a target='_blank' href='https://github.com/Polyplastic/1c-parsing-tech-log'>https://github.com/Polyplastic/1c-parsing-tech-log</a>";
	
КонецФункции


Процедура ОтправитьСообщение(Знач УчетнаяЗапись, Параметры=Неопределено, ТекстСообщения="" ) Экспорт
	
	мНастройки = УправлениеХранилищемНастроекВызовСервера.ДанныеИзБезопасногоХранилища(УчетнаяЗапись);  	

	
	Профиль 					= Новый ИнтернетПочтовыйПрофиль;
	Профиль.АдресСервераSMTP 	= мНастройки.АдресСервераSMTP;
	Профиль.ПользовательSMTP 	= мНастройки.ПользовательSMTP;
	Профиль.Пользователь		= мНастройки.Пользователь;
	Профиль.ПарольSMTP 			= мНастройки.ПарольSMTP;
	Профиль.Пароль 				= мНастройки.Пароль;
	Профиль.ИспользоватьSSLSMTP = мНастройки.ИспользоватьSSLSMTP;
	Профиль.ПортSMTP 			= мНастройки.ПортSMTP; 
	Профиль.АутентификацияSMTP 	= СпособSMTPАутентификации[мНастройки.АутентификацияSMTP];
	
	Письмо = Новый ИнтернетПочтовоеСообщение;
	Текст 					= Письмо.Тексты.Добавить(ТекстСообщения);
	Текст.ТипТекста 		= ТипТекстаПочтовогоСообщения.ПростойТекст;
	Письмо.Тема 			= мНастройки.Тема; 
	Письмо.Отправитель 		= мНастройки.Отправитель;
	Письмо.ИмяОтправителя 	= мНастройки.ИмяОтправителя;
	
	Получатели = СтрЗаменить(мНастройки.Получатели,";",",");
	СписокПолучателей = СтрРазделить(Получатели,",",Ложь);
	
	Для каждого стр из СписокПолучателей Цикл
		Письмо.Получатели.Добавить(стр);
	КонецЦикла;
	
	Почта = Новый ИнтернетПочта;     
	Попытка
		Почта.Подключиться(Профиль);
	Исключение
		ЗаписьЖурналаРегистрации("ОтправкаСообщенийAPI_email.ОтправитьСообщение",УровеньЖурналаРегистрации.Ошибка,,,"Не удалось подключиться к серверу"+Символы.ПС+ОписаниеОшибки());
	КонецПопытки;
	Попытка
		Почта.Послать(Письмо);
	Исключение
		ЗаписьЖурналаРегистрации("ОтправкаСообщенийAPI_email.ОтправитьСообщение",УровеньЖурналаРегистрации.Ошибка,,,"Не удалось отправить письмо"+Символы.ПС+ОписаниеОшибки());

	КонецПопытки;
	
	Почта.Отключиться();
   
КонецПроцедуры

#КонецОбласти   