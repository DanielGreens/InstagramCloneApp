//
//  SelectImageVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 25/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerReuseIdentifier = "SelectPhotoHeader"

//Выбор фото для публикации
class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Свойства
    
    ///Массив загруженных фотографий из библиотеки
    var images = [UIImage]()
    
    ///Массив данных о загруженных фотографиях из библиотеки
    var asset = [PHAsset]()
    
    ///Выбранная пользователем фотография
    var selectedImage: UIImage?
    
    ///Верхняя часть CollectionView
    var header: SelectPhotoHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        
        collectionView.backgroundColor = .white
        configureNavigationButtons()
        fetchPhotos()
    }
    
    // MARK: - CollectionView Data Source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        
        cell.photoImageView.image = images[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        //Чтобы картинка отображалась в лучшей качестве и не была размазана, то мы загружаем картинку по ее данным из фото библиотеки уже с лучшим качеством
        if let selectedImage = self.selectedImage {
            
            //Получаем индекс выбранной картинки
            if let index = self.images.firstIndex(of: selectedImage) {
                
                //Получаем данные о ней
                let selectedAsset = self.asset[index]
                
                let imageManager = PHImageManager.default()
                //Делаем больший размер фотографии
                let targetSize = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
        }
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        //Прокручиаем нашу коллекцию наверх, когда опльзователь выбирает фотографию
        let indexPathForScroll = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPathForScroll, at: .bottom, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Мы делаем такую формулу, потому что хотим получить 4 колонки, разделенные тремя сепараторами. Эти 3 сепаратора и займут эти 3 пикселя, которые мы вычли из ширина окна.
        let width = (view.frame.width - 3) / 4
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: - Кнопки навигации
    
    func configureNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(handleTapBackButton))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(handleTapNextButton))
    }
    
    // MARK: - Обработка нажатий кнопок
    
    @objc func handleTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTapNextButton() {
        let uploadPhoto = UploadPostVC()
        uploadPhoto.photoImageView.image = header?.photoImageView.image
        uploadPhoto.uploadAction = UploadPostVC.UploadAction.UploadPost
        navigationController?.pushViewController(uploadPhoto, animated: true)
    }
    
    // MARK: - Загружаем фото из Библиотеки
    
    ///Загружает фото из фото библиотеки
    private func fetchPhotos() {

        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        //Загружаем фото в фоновом потоке
        DispatchQueue.global(qos: .background).async {
            
            //Проходим по всем полученным фотографиям
            allPhotos.enumerateObjects({ (asset, count, stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        
                        self.images.append(image)
                        self.asset.append(asset)
                        //При открытии данного экрана, выбранная пользователем фотография инициализируется первой фотографией из библиотеки
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    //Когда мы долшли до последней загруженной фотографии, нам необходимо обновить collectionView полученными данными
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                })
            })
            
        }
        
    }
    
    ///Настраивает опции, по которым будет производится загрузка изображений и возвращает настроенный объект
    private func getAssetFetchOptions() -> PHFetchOptions {
        
        let options = PHFetchOptions()
        
        //Устаналиваем лимит количества фотографий которые мы хотим загрузить
        options.fetchLimit = 30
        
        //Соритруем фото по дате
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        options.sortDescriptors = [sortDescriptor]
        
        return options
    }
    
}
