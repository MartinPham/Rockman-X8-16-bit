extends CanvasLayer
class_name AchievementPopup

const outscreen_position: float = 227.0
const title_limit: int = 28
const disc_limit: int = 48

onready var popup: Control = $popup
onready var show_position: Vector2 = popup.rect_position
onready var tween: TweenController = TweenController.new(self, false)
onready var sound: AudioStreamPlayer = $achieve_sound
onready var achievement_title: Label = $popup / title
onready var achievement_disc: Label = $popup / disc
onready var icon: TextureRect = $popup / icon
onready var save_icon: TextureRect = $save_icon

var queued_achievements: Array
var showing: bool = false


func _ready() -> void :
	popup.rect_position.y = outscreen_position

func show_achievement(achievement: Achievement) -> void :
	if Configurations.get("ShowAchievements"):
		queued_achievements.append(achievement)
		setup_next_achievement()

func setup_next_achievement() -> void :
	if queued_achievements.size() == 0:
		return
	if not showing:
		setup(queued_achievements[0])
		display()

func setup(achievement: Achievement) -> void :
	achievement_title.text = achievement.get_title()
	achievement_disc.text = achievement.get_description()
	var too_long: bool = false
	while achievement_disc.get_line_count() >= 3:
		too_long = true
		achievement_disc.text = achievement_disc.text.substr(0, achievement_disc.text.length() - 1)
	if too_long:
		achievement_disc.text = achievement_disc.text.substr(0, achievement_disc.text.length() - 3) + "..."
	icon.texture = achievement.icon
	queued_achievements.erase(achievement)
	handle_cheaters()

func handle_cheaters() -> void :
	if GameManager.is_cheating():
		achievement_title.text = tr("DEBUGACHIEVTITLE")

func display() -> void :
	showing = true
	sound.play()
	tween.attribute("rect_position:y", show_position.y, 0.5, popup)
	tween.add_wait(3.0)
	tween.add_attribute("rect_position:y", outscreen_position, 0.5, popup)
	tween.add_callback("finished_displaying")

func finished_displaying() -> void :
	showing = false
	setup_next_achievement()
