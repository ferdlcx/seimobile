# ALUR BERSAMA · semua aktor

## Judul grup

```xml
<TextView
android:id="@+id/alur_bersam"
android:layout_width="408dp"
android:layout_height="34dp"
android:text="@string/alur_bersam"
android:textAppearance="@style/alur_bersam"
android:gravity="top"
 />
<!--
Font family: Bricolage Grotesque
Line height: 34sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="alur_bersam">
<item name="android:textSize">28sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="alur_bersam">
ALUR BERSAMA \u00c2\u00b7 semua aktor
</string>
```

## 1. Splash

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/splash"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/splash"
 />

<!-- drawable/splash.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/splash"
android:layout_width="46dp"
android:layout_height="18dp"
android:text="@string/splash"
android:textAppearance="@style/splash"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="splash">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="splash">
Splash
</string>
```

## 2. Pilih Peran

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/pilih_peran"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/pilih_peran"
 />

<!-- drawable/pilih_peran.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/pilih_peran"
android:layout_width="73dp"
android:layout_height="18dp"
android:text="@string/pilih_peran"
android:textAppearance="@style/pilih_peran"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="pilih_peran">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="pilih_peran">
Pilih Peran
</string>
```

## 3. Login Admin

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/login_admin"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/login_admin"
 />

<!-- drawable/login_admin.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/login_admin"
android:layout_width="87dp"
android:layout_height="18dp"
android:text="@string/login_admin"
android:textAppearance="@style/login_admin"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="login_admin">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="login_admin">
Login Admin
</string>
```

## 4. Login Sales

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/login_sales"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/login_sales"
 />

<!-- drawable/login_sales.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/login_sales"
android:layout_width="78dp"
android:layout_height="18dp"
android:text="@string/login_sales"
android:textAppearance="@style/login_sales"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="login_sales">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="login_sales">
Login Sales
</string>
```

## 5. Login Manajer

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/login_manaj"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/login_manaj"
 />

<!-- drawable/login_manaj.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/login_manaj"
android:layout_width="98dp"
android:layout_height="18dp"
android:text="@string/login_manaj"
android:textAppearance="@style/login_manaj"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="login_manaj">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="login_manaj">
Login Manajer
</string>
```

## 6. Validasi Admin

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/validasi_ad"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/validasi_ad"
 />

<!-- drawable/validasi_ad.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/validasi_ad"
android:layout_width="103dp"
android:layout_height="18dp"
android:text="@string/validasi_ad"
android:textAppearance="@style/validasi_ad"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="validasi_ad">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="validasi_ad">
Validasi Admin
</string>
```

## 7. Validasi Sales

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/validasi_sa"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/validasi_sa"
 />

<!-- drawable/validasi_sa.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/validasi_sa"
android:layout_width="94dp"
android:layout_height="18dp"
android:text="@string/validasi_sa"
android:textAppearance="@style/validasi_sa"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="validasi_sa">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="validasi_sa">
Validasi Sales
</string>
```

## 8. Validasi Manajer

```xml
<RelativeLayout
xmlns:android="http://schemas.android.com/apk/res/android"
android:id="@+id/validasi_ma"
android:layout_width="390dp"
android:layout_height="800dp"
android:clipToOutline="true"
android:background="@drawable/validasi_ma"
 />

<!-- drawable/validasi_ma.xml -->
<vector
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:aapt="http://schemas.android.com/aapt"
android:width="390dp"
android:height="800dp"
android:viewportWidth="390"
android:viewportHeight="800"
 >
<group>
<clip-path
android:pathData="M40 0H350C372.091 0 390 17.9086 390 40V760C390 782.091 372.091 800 350 800H40C17.9086 800 0 782.091 0 760V40C0 17.9086 17.9086 0 40 0Z"
/>
<path
android:pathData="M0 0V800H390V0"
android:fillColor="#0B1B3A"
/>
</group>
</vector>


<TextView
android:id="@+id/validasi_ma"
android:layout_width="113dp"
android:layout_height="18dp"
android:text="@string/validasi_ma"
android:textAppearance="@style/validasi_ma"
android:gravity="top"
 />
<!--
Font family: Figtree
Line height: 18sp
(identical to box height)
-->

<!-- styles.xml -->
<style name="validasi_ma">
<item name="android:textSize">15sp</item>
<item name="android:textColor">#0B1B3A</item>
</style>

<!-- strings.xml -->
<string name="validasi_ma">
Validasi Manajer
</string>
```
