extends Control

@onready var grid_container = $CenterContainer/Control/PanelContainer/PanelContainer/VBoxContainer/HBoxContainer/News/GridContainer

func _ready() -> void:
	SignalBus.articles_changed.connect(_load_articles)
	if Global.articles.size() > 0:
		_load_articles()

func _load_articles():
	for child in grid_container.get_children():
		child.queue_free()
 
	var packed = preload("res://scenes/article.tscn")
	var index = 0
	for article in Global.articles:
		var storage_ui = packed.instantiate()
		storage_ui.pick_random = false
		storage_ui.article_index = index
		index += 1
		grid_container.add_child(storage_ui)
		storage_ui.process_article(article)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
