﻿
Процедура СоздатьЕжедневныйОтчет() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СведенияОСотрудниках.Сотрудник КАК Сотрудник
		|ИЗ
		|	РегистрСведений.СведенияОСотрудниках КАК СведенияОСотрудниках
		|		ЛЕВОЕ СОЕДИНЕНИЕ Задача.Задача КАК Задача
		|		ПО СведенияОСотрудниках.Сотрудник = Задача.Сотрудник
		|			И (Задача.Дата = &ТекущаяДатаЗадачи)
		|			И НЕ (Задача.ПометкаУдаления)
		|ГДЕ
		|	СведенияОСотрудниках.Период <= &ТекущаяДата
		|	И Задача.Сотрудник IS NULL";
	
	лДатаЗадач = КонецДня(ТекущаяДата());
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата());
	Запрос.УстановитьПараметр("ТекущаяДатаЗадачи", лДатаЗадач);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ЗадачаБД = Задачи.Задача.СоздатьЗадачу();
		
		ЗадачаБД.Дата = лДатаЗадач;
		ЗадачаБД.Сотрудник = ВыборкаДетальныеЗаписи.Сотрудник;
		ЗадачаБД.Наименование = "Отчет о проделанной работ";
		ЗадачаБД.Записать();
		
		
		// Вставить обработку выборки ВыборкаДетальныеЗаписи
	КонецЦикла;
	
КонецПроцедуры
