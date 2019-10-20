using UnityEngine;
using System.Collections;

public class NavTestClick : MonoBehaviour {

    public Transform hero;
    public Transform flag;
    private NavMeshAgent heroAgent;

    // Use this for initialization
    void Start () {
        // 获取导航代理
        heroAgent = hero.GetComponent<NavMeshAgent>();
        flag.transform.position = Vector3.zero;
    }
    
    // Update is called once per frame
    void Update () {
        transform.LookAt(hero);
        if(Input.GetMouseButtonDown(0))
        {
            // 创建射线，从屏幕垂直而下的射线
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            // 创建射线撞击
            RaycastHit hit;
            // 进行发射射线，并保存撞击结果
            if (Physics.Raycast(ray, out hit))
            {
                //为代理设置目的地
                heroAgent.SetDestination(hit.point);
                flag.transform.position = hit.point;
            }
        }
    }
}
