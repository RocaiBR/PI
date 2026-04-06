Permissões de plataforma não configuradas

Os pacotes image_picker e file_picker precisam de permissões declaradas manualmente. Sem isso o app crasha no dispositivo físico.
Android — em android/app/src/main/AndroidManifest.xml, antes de <application>:


<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
