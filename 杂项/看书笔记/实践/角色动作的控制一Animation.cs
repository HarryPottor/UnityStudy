using UnityEngine;
using System.Collections;

public class HeroAnimation : MonoBehaviour {

    private NavMeshAgent heroAgent;
    private Animation heroAnimation;
    private string aniString;
    private bool lerpBool;
    private Vector3 lerpStart;
    private Vector3 lerpEnd;
    private float lerpRatio;


    // Use this for initialization
    void Start () {
        // 寻路代理
        heroAgent = GetComponent<NavMeshAgent>();
        // 动画播放器
        heroAnimation = GetComponent<Animation>();
        aniString = "hit1";
    }
    
    // Update is called once per frame
    void Update () {
        if (heroAgent.hasPath)
        {
            transform.LookAt(heroAgent.nextPosition);
            aniString = "run";
            heroAnimation.wrapMode = WrapMode.Loop;
            if (heroAgent.isOnOffMeshLink)
            {
                OffMeshLink link = heroAgent.currentOffMeshLinkData.offMeshLink;
                if (link.name == "UpLine")
                {
                    aniString = "jump";
                }
                else if (link.name == "DownLine")
                {
                    aniString = "casting";
                }
                lerpStart = link.startTransform.position;
                lerpEnd = link.endTransform.position;
                lerpBool = true;
                lerpRatio = Time.time;
            }
        }
        else
        {
            aniString = "hit1";
            heroAnimation.wrapMode = WrapMode.Once;
        }
        // 动画播放器 播放动画
        heroAnimation.Play(aniString);
        if (lerpBool)
        {
            transform.position = Vector3.Lerp(lerpStart, lerpEnd, (Time.time - lerpRatio) * 2);
            if (transform.position == lerpEnd)
            {
                lerpBool = false;
            }
        }
    }
}
