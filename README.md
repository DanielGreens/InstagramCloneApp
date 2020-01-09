#  Учебный проект целью которого являлась разработка приложения похожего по функционалу на Instagram, который работает на БД Firebase.

Данное приложение разработанно в рамках самообучения программированию на языке Swift.
Разработанное приложение повторяет основной функционал известного притложения Instagram. 

Все экраны реализованы без использования Storyboards.

#  Функционал приложения

##  Авторизация и регистрация

Приложение начинается с экрана авторизации, где пользователю необходимо ввести свой логин и пароль.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/Login.png">
</p>

Если у пользователя нету аккаунта, то он имеет возможность зарегестрироваться, заполнив необходимые поля формы регистрации.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/Registration.png">
</p>

##  Лента пользователя

Лента пользователя представляет публикации пользователей на которых подписан текущий пользователь. Публикации можно лайкать и оставлять под ними комментарии. Так же хочется отметить, что публикации загружаются по 5 постов, остальные подгружаются по мере необходимости.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/Feed.png">
</p>

Так же при публикации нового поста, пользователь может упомянуть пользователя указав его имя в формате **@username**, тогда упомянутый пользователь получит соответствубщее уведомление об этом на экране уведомлений. Так же при публикации поста, можно указать **хэштег** для него.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/FeedWithMentionandHastag.png">
<img width="318" height="551" src="./ReadmeResourses/blackHashtag.png">
</p>

Оставляя комментарий под постом так же можно упомянуть пользователя, чтобы он получил уведомление об этом.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/Comments.png">
<img width="318" height="551" src="./ReadmeResourses/Comments 2.png">
</p>

##  Поиск

По умолчанию приложение отображает страницу на которой отобрадаются все опубликованные изображения всеми пользователями.

 <p align="center"> 
<img width="318" height="551" src="./Search/Feed.png">
</p>

Если нажать на строку поиска, то отобразится экран поиска по всем пользотвателям зарегестрированным в приложении.

 <p align="center"> 
<img width="318" height="551" src="./Search/UserSearch.png">
</p>

##  Публикация изображения

Пользователь выбирает изображение из его фотогалереи. Затем добавляет к нему описание и публикует.

 <p align="center"> 
<img width="318" height="551" src="./Search/UploadPhoto.png">
</p>

##  Центр уведомлений

Если пользователь зашел в приложение и у него есть непрочитанные уведомлений то это оповестит соответствующий индикатор.

 <p align="center"> 
<img width="318" height="551" src="./Search/NotificationPoint.png">
</p>

Как можно заметить уведолмения бывают разных типов. Если пользователь на нас подписался, но рядом с уведомлением будет кнопка подписаться на этого пользовтаеля, если мы на него уже подписаны, то будет кнопка отписаться. Так же уведолмения об упоминании пользователя, о том что кто-либо лайкнул какую-либо публикацию так же присутствуют.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/NotificationStark.png">
<img width="318" height="551" src="./ReadmeResourses/NotificationTor.png">
</p>


##  Экран профиля

Тут по традиции представлена краткая информация о пользователе и его публикациях. 

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/TonyProfile.png">
<img width="318" height="551" src="./ReadmeResourses/TorProfile.png">
</p>

Так же можно посмотреть его подписки и подписчиков имея возможность подписаться на пользователя или отписаться.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/TorFollowers.png">
</p>

##  Экран сообщений

В приложении есть возможность переписываться с пользователями которые подписаны на текущего пользователя. Сообщения сортируются по новизне. Чтобы написать пользователю нужно выбрать соответствующий диалог или нажать **+** и выбрать пользователя чтобы начать диалоог.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/Messages.png">
</p>

Экран переписки выглядит следующим образом.

 <p align="center"> 
<img width="318" height="551" src="./ReadmeResourses/MessagesTony.png">
<img width="318" height="551" src="./ReadmeResourses/MessagesTor.png">
</p>
