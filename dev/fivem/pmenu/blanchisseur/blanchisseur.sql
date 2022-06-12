
INSERT INTO `addon_account` (name, label, shared) VALUES 
('organisation_blanchisseur', 'blanchisseur', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
('organisation_blanchisseur', 'blanchisseur', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
('organisation_blanchisseur', 'blanchisseur', 1)
;

INSERT INTO `org` (`name`, `label`) VALUES
('blanchisseur', 'Blanchisseur')
;

INSERT INTO `org_gradeorg` ( id, `org_name`, `gradeorg`, `name`, `label`, `skin_male`, `skin_female`, `salary`) VALUES
	(40 , 'blanchisseur', 0, 'blanchisseur', ' ', '{}', '{}', 0)

;