/obj/item/organ/heart
	/// Markings on this heart for the maniac antagonist.
	/// Assoc list using Maniac antag datums as keys. One for each maniac, but not for each wonder.
	var/inscryptions = list()
	/// Assoc list tracking antag datums to 4-letter maniac keys
	var/inscryption_keys = list()
	/// Assoc list tracking antag datums to wonder ID number (1-4)
	var/maniacs2wonder_ids = list()
	/// List of Maniac datums that have inscribed on this heart
	var/maniacs = list()
