using UnityEngine;
using System.Collections;

public class ClickListener : MonoBehaviour {

    public Transform hero;
    private NavMeshAgent heroAgent;
    public Transform flag;
    private Vector3 distance;
    private Rect buttonRect0;
    private Rect buttonRect1;
    private Vector2 beganPoint;
    public Texture2D buttonAddTex;
    public Texture2D buttonMoveTex;
    void Start () {
        heroAgent = hero.GetComponent<NavMeshAgent>();
        flag.transform.position = Vector3.zero;
        buttonRect0 = new Rect(30, Screen.height - 40 - Screen.height * 0.1f, Screen.height * 0.15f, Screen.height * 0.15f);
        buttonRect1 = new Rect(30, Screen.height - 80 - Screen.height * 0.2f, Screen.height * 0.15f, Screen.height * 0.15f);
    }
    void Update () {
        // 水平变换值
        float horizontal = Input.GetAxis("Horizontal");
        // 转向玩家
        transform.LookAt(hero);
        // touchCount 触摸的个数
        if (Input.touchCount != 0) {                    //触摸点击
            // 触摸的位置不在按钮范围内
            if (touchIn(Input.touches[0].position)) {
                return;
            }
            // 触摸的状态为移动时，deltaPosition 手指每一帧的移动
            if (Input.touches[0].phase == TouchPhase.Moved) {
                horizontal = Input.touches[0].deltaPosition.x * 0.2f;
            }
            if (Input.touches[0].phase == TouchPhase.Began) {
                beganPoint = Input.touches[0].position;
            }
            if (Input.touches[0].phase == TouchPhase.Ended) {
                if (Vector2.Distance(Input.touches[0].position, beganPoint) < Screen.height * 0.1f) {
                    Ray ray = Camera.main.ScreenPointToRay(Input.touches[0].position);
                    RaycastHit hit;
                    if (Physics.Raycast(ray, out hit)) {
                        heroAgent.SetDestination(hit.point);
                        flag.transform.position = hit.point;
                    }
                }
            }
        }
        if (Input.GetMouseButtonDown(0))
        {
            beganPoint = Input.mousePosition;
            Ray ray = Camera.main.ScreenPointToRay(beganPoint);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                Debug.Log(hit.point);
                heroAgent.SetDestination(hit.point);
                flag.transform.position = hit.point;
            }
        }

        transform.RotateAround(hero.position, Vector3.up, horizontal); 
        distance = Vector3.Normalize(hero.position - transform.position);
    }
    void OnGUI() {
        if (GUI.RepeatButton(buttonRect0, buttonAddTex, new GUIStyle()))
        {
            transform.position += distance;
        }
        if (GUI.RepeatButton(buttonRect1, buttonMoveTex, new GUIStyle()))
        {
            transform.position -= distance;
        }
    }
    bool touchIn(Vector2 touchPostion) {
        touchPostion = new Vector2(touchPostion.x, Screen.height - touchPostion.y);
        if ((touchPostion.x > buttonRect0.xMin && touchPostion.x < buttonRect0.xMax &&
             touchPostion.y > buttonRect0.yMin && touchPostion.y < buttonRect0.yMax)||
             (touchPostion.x > buttonRect1.xMin && touchPostion.x < buttonRect1.xMax &&
             touchPostion.y > buttonRect1.yMin && touchPostion.y < buttonRect1.yMax)) {
                 return true;
        }
        return false;
    }
}
