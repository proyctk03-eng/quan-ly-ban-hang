-- =====================================================================
-- BÀI TẬP: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ BÁN HÀNG
-- TÊN CƠ SỞ DỮ LIỆU: QuanLyBanHang
-- HỆ QUẢN TRỊ CSDL: MySQL 8.0+
-- TẬP TIN: QuanLyBanHang.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- PHẦN 1: TẠO CƠ SỞ DỮ LIỆU
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS QuanLyBanHang;
CREATE DATABASE QuanLyBanHang 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE QuanLyBanHang;

-- ---------------------------------------------------------------------
-- PHẦN 2: TẠO CÁC BẢNG & RÀNG BUỘC (CONSTRAINTS)
-- ---------------------------------------------------------------------

-- Bảng 1: Customer (Lưu danh sách khách hàng đến cửa hàng)
CREATE TABLE Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(50) NOT NULL COMMENT 'Tên khách hàng',
    cAge TINYINT NOT NULL COMMENT 'Tuổi khách hàng',
    CONSTRAINT chk_customer_age CHECK (cAge > 0 AND cAge <= 120)
) ENGINE=InnoDB;

-- Bảng 2: `Order` (Lưu thông tin hóa đơn mua hàng của khách)
-- Lưu ý: 'Order' là từ khóa dự trữ trong SQL nên được bọc trong cặp dấu backtick
CREATE TABLE `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL COMMENT 'Mã khách hàng mua hàng',
    oDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày mua hàng',
    oTotalPrice INT NULL DEFAULT NULL COMMENT 'Tổng số tiền hóa đơn',
    
    -- Khóa ngoại liên kết tới bảng Customer
    CONSTRAINT fk_order_customer 
        FOREIGN KEY (cID) REFERENCES Customer(cID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Bảng 3: Product (Lưu danh mục sản phẩm của cửa hàng)
CREATE TABLE Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(50) NOT NULL COMMENT 'Tên sản phẩm',
    pPrice INT NOT NULL COMMENT 'Đơn giá sản phẩm',
    CONSTRAINT chk_product_price CHECK (pPrice >= 0)
) ENGINE=InnoDB;

-- Bảng 4: OrderDetail (Chi tiết các mặt hàng trong từng hóa đơn)
-- Mối quan hệ N-N giữa Order và Product được chuẩn hóa thành 1-N và N-1
CREATE TABLE OrderDetail (
    oID INT NOT NULL COMMENT 'Số hóa đơn',
    pID INT NOT NULL COMMENT 'Mã sản phẩm',
    odQTY INT NOT NULL COMMENT 'Số lượng sản phẩm mua',
    
    -- Khóa chính phức hợp (Composite Primary Key)
    PRIMARY KEY (oID, pID),
    
    -- Khóa ngoại liên kết tới bảng Order
    CONSTRAINT fk_orderdetail_order 
        FOREIGN KEY (oID) REFERENCES `Order`(oID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
        
    -- Khóa ngoại liên kết tới bảng Product
    CONSTRAINT fk_orderdetail_product 
        FOREIGN KEY (pID) REFERENCES Product(pID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
        
    -- Ràng buộc số lượng mặt hàng mua phải lớn hơn 0
    CONSTRAINT chk_orderdetail_qty CHECK (odQTY > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- PHẦN 3: TỐI ƯU HÓA CHỈ MỤC (INDEXES)
-- ---------------------------------------------------------------------
CREATE INDEX idx_order_cid ON `Order`(cID);
CREATE INDEX idx_orderdetail_pid ON OrderDetail(pID);

-- ---------------------------------------------------------------------
-- PHẦN 4: DỮ LIỆU MÔ PHỎNG MẪU (DML INSERTION)
-- ---------------------------------------------------------------------

-- 4.1. Chèn dữ liệu khách hàng (Gồm cả khách có mua hàng và không mua hàng)
INSERT INTO Customer (cID, cName, cAge) VALUES
    (1, 'Minh Quan', 10),
    (2, 'Ngoc Oanh', 20),
    (3, 'Hong Ha', 50);

-- 4.2. Chèn dữ liệu sản phẩm
INSERT INTO Product (pID, pName, pPrice) VALUES
    (1, 'May Giat', 3),
    (2, 'Tu Lanh', 5),
    (3, 'Dieu Hoa', 7),
    (4, 'Quat', 1),
    (5, 'Bep Dien', 2);

-- 4.3. Chèn dữ liệu hóa đơn mua hàng
INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
    (1, 1, '2006-03-21', NULL),
    (2, 2, '2006-03-23', NULL),
    (3, 1, '2006-03-16', NULL);

-- 4.4. Chèn chi tiết các mặt hàng trong hóa đơn
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
    (1, 1, 3), -- Hóa đơn 1: Mua 3 Máy giặt
    (1, 3, 7), -- Hóa đơn 1: Mua 7 Điều hòa
    (1, 4, 2), -- Hóa đơn 1: Mua 2 Quạt
    (2, 1, 1), -- Hóa đơn 2: Mua 1 Máy giặt
    (3, 1, 8), -- Hóa đơn 3: Mua 8 Máy giặt
    (2, 5, 4), -- Hóa đơn 2: Mua 4 Bếp điện
    (2, 3, 3); -- Hóa đơn 2: Mua 3 Điều hòa

-- ---------------------------------------------------------------------
-- PHẦN 5: CÁC TRUY VẤN NGHIỆP VỤ MẪU (VERIFICATION QUERIES)
-- ---------------------------------------------------------------------

-- Truy vấn 1: Hiển thị các thông tin gồm oID, oDate, oTotalPrice của tất cả các hóa đơn
SELECT 
    oID AS 'Mã HĐ',
    oDate AS 'Ngày Bán',
    oTotalPrice AS 'Tổng Tiền'
FROM `Order`;

-- Truy vấn 2: Hiển thị danh sách các khách hàng đã mua hàng và danh sách sản phẩm được mua
SELECT 
    c.cName AS 'Khách Hàng',
    p.pName AS 'Sản Phẩm Đã Mua',
    od.odQTY AS 'Số Lượng'
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
ORDER BY c.cName;

-- Truy vấn 3: Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
SELECT 
    c.cID AS 'Mã Khách',
    c.cName AS 'Khách Hàng',
    c.cAge AS 'Tuổi'
FROM Customer c
LEFT JOIN `Order` o ON c.cID = o.cID
WHERE o.oID IS NULL;

-- Truy vấn 4: Hiển thị mã hóa đơn, ngày bán và tổng giá tiền của từng hóa đơn
-- (Tính toán từ: tổng các (odQTY * pPrice))
SELECT 
    o.oID AS 'Mã Hóa Đơn',
    o.oDate AS 'Ngày Lập Hóa Đơn',
    SUM(od.odQTY * p.pPrice) AS 'Tổng Giá Tiền (Total)'
FROM `Order` o
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
GROUP BY o.oID, o.oDate;

-- Cập nhật ngược lại tổng tiền vào cột oTotalPrice của bảng Order
UPDATE `Order` o
JOIN (
    SELECT oID, SUM(odQTY * pPrice) AS Total
    FROM OrderDetail od
    JOIN Product p ON od.pID = p.pID
    GROUP BY oID
) t ON o.oID = t.oID
SET o.oTotalPrice = t.Total;
