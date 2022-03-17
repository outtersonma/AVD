#Create Azure Compute Gallery - Working
$ACGRes = "rg-uks-avd-images"
$location = "UKSouth"
$ACGName = "ACGAVD"
$galleryImageDefinitionName = "Gold"
$publisherName = "Microsoft"
$offerName ="AVDOS"
$skuName = "XXXXX"
New-AzGallery -ResourceGroupName "$ACGRes" -Name "$ACGName" -Location "$location" -Description 'Azure Compute Gallery for my organization'

#Create Image definition - Working
$rgName = "$ACGRes"
$galleryName = "$ACGName"
$description = "My Gold Image"
$IsHibernateSupported = @{Name='IsHibernateSupported';Value='True'}
$IsAcceleratedNetworkSupported = @{Name='IsAcceleratedNetworkSupported';Value='True'}
$features = @($IsHibernateSupported,$IsAcceleratedNetworkSupported)
New-AzGalleryImageDefinition -ResourceGroupName $rgName -GalleryName $galleryName -Name $galleryImageDefinitionName -Location $location -Publisher $publisherName -Offer $offerName -Sku $skuName -OsState "Generalized" -OsType "Windows" -Description $description -Feature $features -HyperVGeneration "V2"
