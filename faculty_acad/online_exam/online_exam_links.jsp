<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<link href="../../css/regmainlinkcss.css" rel="stylesheet" type="text/css">
<style>
body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
	color:#FFFFFF;
}

</style>
</head>
<body bgcolor="#C39E60" onLoad="MM_preloadImages('../../images/home_small_admin_rollover.gif','../../images/help_small_admin_rollover.gif','../../images/logout_admin_rollover.gif')">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<script language="JavaScript">
var openImg = new Image();
openImg.src = "../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
</script>
<form action="../../commfile/logout.jsp" method="post" target="_parent">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="8%" height="19" bgcolor="#E9E0D1">&nbsp;</td>
    <td width="92%" bgcolor="#E9E0D1"><a href="../faculty_acad_bottom_content.htm" target="_parent" onMouseOver="MM_swapImage('Image2','','../../images/home_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small_admin.gif" name="Image2" width="65" height="22" border="0" id="Image2"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image1','','../../images/help_small_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small_admin.gif" name="Image1" width="65" height="22" border="0" id="Image1"></a><a onMouseOver="MM_swapImage('Image3','','../../images/logout_admin_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout_admin.gif" name="Image3" width="65" height="22" border="0" id="Image3"></a></td>
  </tr>
  </table>
<input type="hidden" name="logout_url" value="../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm">
<input type="hidden" name="body_color" value="#C39E60">
</form>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" border="0" id="folder1"> 
  <strong>QUESTION BANK </strong></div>

<span class="branch" id="branch1"> 
<img src="../../images/broken_lines.gif"> <a href="question_bank/online_exam_question_bank_create.jsp" target="onlineexamFrame">Add/Create</a><br>
<img src="../../images/broken_lines.gif"> <a href="question_bank/online_exam_question_bank_edit_delete_view.jsp" target="onlineexamFrame">Edit/Delete/View</a><br>
<img src="../../images/broken_lines.gif"> <a href="question_bank/statistics.jsp" target="onlineexamFrame">Statistics</a><br>
</span> 
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"><img src="../../images/box_with_plus.gif" border="0" id="folder2"> 
  <strong>QUESTIONNAIRES</strong></div>

<span class="branch" id="branch2"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font> 
<img src="../../images/broken_lines.gif"> <a href="questionnaires/questionnaires_create.jsp" target="onlineexamFrame">Set Parameters</a><br>
<img src="../../images/broken_lines.gif"> <a href="questionnaires/questionnaire_edit_delete_view.jsp" target="onlineexamFrame">Edit/Delete/View</a><br>
<img src="../../images/broken_lines.gif"> <a href="questionnaires/questionnaires_offline_create1.jsp" target="onlineexamFrame">Generate (Offline Exam)</a><br>
</span>

<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"><img src="../../images/box_with_plus.gif" border="0" id="folder3"> 
  <strong>EXAM SCHEDULING</strong></div>
<span class="branch" id="branch3"> 
<img src="../../images/broken_lines.gif"> <a href="exam_scheduling/online_exam_sched_create.jsp" target="onlineexamFrame">Add/Create</a><br>
<img src="../../images/broken_lines.gif"> <a href="exam_scheduling/online_exam_sched_edit_delete_view.jsp" target="onlineexamFrame">Edit/Delete</a><br>
<img src="../../images/broken_lines.gif"> <a href="exam_scheduling/online_exam_sched_view.jsp" target="onlineexamFrame">Print Schedules </a><br>
</span>
<%if(false){%>
<div class="trigger" onClick="showBranch('branch4');swapFolder('folder4')"><img src="../../images/box_with_plus.gif" border="0" id="folder4"> 
  <strong>EXAM RESULTS</strong></div>
<span class="branch" id="branch4"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"></font> 
<img src="../../images/broken_lines.gif"> <a href="exam_results/exam_result_encode.jsp" target="onlineexamFrame">Encode Results (Offline Exam)</a><br>
<img src="../../images/broken_lines.gif"> <a href="exam_results/exam_result_view.jsp" target="onlineexamFrame">View Results</a><br>
<img src="../../images/broken_lines.gif"> <a href="exam_results/exam_result_edit.jsp" target="onlineexamFrame">Edit Results(Offline Exam)</a><br>
</span> 

<div class="trigger" onClick="showBranch('branch6');swapFolder('folder6')"> <img src="../../images/box_with_plus.gif" border="0" id="folder6"> <strong><font color="#FFFFFF" size="2" face="Geneva, Arial, Helvetica, sans-serif">STATISTICS</font></strong></div>
<span class="branch" id="branch6"> 
<img src="../../images/broken_lines.gif">Scores<br>
<img src="../../images/broken_lines.gif">Questions<br>
</span>
<%}%>

  </body>
</html>
