using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using System;

namespace FogShader {

  public class GUI : ShaderGUI {
    MaterialProperty Mode;
    MaterialProperty Density;
    MaterialProperty Start;
    MaterialProperty End;

    int Version_H = 1;
    int Version_M = 0;
    int Version_L = 0;

    public override void OnGUI(MaterialEditor ME , MaterialProperty[] Prop) {

      var mat = (Material) ME.target;

      Mode = FindProperty("_Mode", Prop , false);
      Density = FindProperty("_Density", Prop , false);
      Start = FindProperty("_Start", Prop , false);
      End = FindProperty("_End", Prop , false);

      using (new EditorGUILayout.VerticalScope("box")) {
        GUILayout.Label("Fog", EditorStyles.boldLabel);

        ME.ShaderProperty(Mode, new GUIContent("Mode")); 
        
        if (mat.GetInt("_Mode") == 0) {
          ME.ShaderProperty(Start, new GUIContent("Start"));
          ME.ShaderProperty(End, new GUIContent("End"));
        } else {
          ME.ShaderProperty(Density, new GUIContent("Density"));
        }
      }

      EditorGUILayout.BeginHorizontal();
      GUILayout.FlexibleSpace();
      GUILayout.Label("Fog Shader " + Version_H + "." + Version_M + "." + Version_L , EditorStyles.boldLabel);
      EditorGUILayout.EndHorizontal();
    }
  }

  public class SToggleDrawer : MaterialPropertyDrawer {
    public override void OnGUI(Rect Pos, MaterialProperty Prop, GUIContent Label, MaterialEditor ME) {
      bool IN  = false;
      if (Prop.floatValue >= 0.5f) IN = true;

      var  OUT = EditorGUI.Toggle(Pos, Label, IN);

      if (OUT) {
        Prop.floatValue = 1.0f;
      } else {
        Prop.floatValue = 0.0f;
      }
    }
  }
}
