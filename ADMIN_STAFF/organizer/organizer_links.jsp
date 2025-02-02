<%@ page language="java" import="utility.*, java.util.Vector, organizer.SBEmail"%>
<%
//check if user is logged in, if logged, check authentication list here and allow the authentic user to access the system.
DBOperation dbOP = null;
CommonUtil comUtil = new CommonUtil();
WebInterface WI = new WebInterface(request);

//may be called from my home - for student and faculties.
boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
boolean bolIsParentStud = WI.fillTextValue("is_parent").equals("1");

String strUserId = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
	bolMyHome = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css"><!--copied from calendar-->
<link href="../../css/regmainlinkcssHEALTH.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../jscript/selectnprint.js"></script>
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
function PopNotes()
{
	var pgLoc = "./pop_notes.jsp";
	var win=window.open(pgLoc,"Notes",'width=275,height=400,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<style>
body {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

td {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

th {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

.bodystyle {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}


</style>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body bgcolor="#32466B" onLoad="MM_preloadImages('../../images/buttons/home_roll.gif','../../images/buttons/help_roll.gif','../../images/buttons/logout_roll.gif')">
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

function ReloadPage() {
	document.form_.action = "./organizer_links.jsp";	
	document.form_.submit();
}
function Logout() {
	document.form_.target="_parent";
	document.form_.action = "../../commfile/logout.jsp";
}
function getCalendar() {
	if (document.form_.showCal.value == "0" || document.form_.showCal.value == "null")
		document.form_.showCal.value = "1";
	else
		document.form_.showCal.value = "0";
	document.form_.submit()
}
</script>

<form action="" method="post" name ="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="33"  align="center"> 
<%
String strTemp = null;
if(bolIsParentStud) 
	strTemp = "'../../PARENTS_STUDENTS/parents_student_index.htm' target='_top'";
else if(bolMyHome)
	strTemp = "'../../my_home/my_home_index.htm' target='_parent'";
else
	strTemp = "'../main%20files/admin_staff_home_button_content.htm' target='_parent'";
%>	
		  <a href=<%=strTemp%> onMouseOver="MM_swapImage('Image1','','../../images/home_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/home_small.gif" name="Image1" border="0" id="Image1"></a><a href="javascript:;" onMouseOver="MM_swapImage('Image2','','../../images/help_small_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../../images/help_small.gif" name="Image2"  border="0" id="Image2"></a> 
          <a onMouseOver="MM_swapImage('Image3','','../../images/logout_rollover.gif',1)" onMouseOut="MM_swapImgRestore()"><input type="image" src="../../images/logout.gif" name="Image3" border="0" id="Image3" onClick="javascript:Logout();"></a> 
	</td>
    </tr>
    <tr> 
      <td height="19" ><hr size="1"></td>
    </tr>
  </table>
<%
if(bolIsParentStud) 
	strTemp = "../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm";
else
	strTemp = "../ADMIN_STAFF/main%20files/admin_staff_bottom_content.htm";
%>	
<input type="hidden" name="logout_url" value="<%=strTemp%>">
<input type="hidden" name="body_color" value="#C39E60">
<%	
String strErrMsg = null;
Vector vMsgBox = null;
boolean bolGrantAll = false;
boolean isAuthorized = false;
SBEmail myMailBox = new SBEmail();
if(strUserId != null)
{
	//open dbConnection here to check if user is registered already.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		strErrMsg = "error in opening connection.";
	}

	if(strErrMsg == null)
	{
		//check here the authentication of the user.
		if(comUtil.IsSuperUser(dbOP,strUserId))
			bolGrantAll = true;	//grant all ;-)
	}
vMsgBox = myMailBox.getMsgCount(dbOP, strUserId);
}
else
	strErrMsg = "";

//Another way of checking authorization..
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Organizer");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if(vAuthList.size() > 0 &&  ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0)
		bolGrantAll = true;
}
//old way of calling..
//comUtil.IsAuthorizedSubModule(dbOP,strUserId,"Enrollment","ROOMS MONITORING")!=0

String strCal = null;
strCal = request.getParameter("showCal");
if (strCal != null && strCal.compareTo("1")==0 )
{%>
	<table width="95%" align="center">
	<tr><td><jsp:include page="calendar_inc_roll.jsp"/></td></tr>
	</table>
	<font color="white" size="1"><a href="javascript:getCalendar()">
	<%if (strCal != null && strCal.compareTo("1")==0){%>
	HIDE
	<%}else{%>
	SHOW
	<%}%>
CALENDAR</a></font><br>
<%}%>
<link href="../../css/treelinkcss.css" rel="stylesheet" type="text/css">
<link href="../../css/regmainlinkcssHEALTH.css" rel="stylesheet" type="text/css">
</head>
<%if(bolGrantAll || vAuthList.indexOf("TO DO") != -1 || bolMyHome){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')"> <img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1"> 
  <strong><font color="#FFFFFF">TO DO LIST </font></strong></div>
<span class="branch" id="branch1"> <font color="#FFFFFF">
<img src="../../images/drop_down_lines.gif"> <a href="./to_do.jsp?my_home=<%=WI.fillTextValue("my_home")%>" target="organizermainFrame" onMouseOver="window.status='';return true;">Add/View List</a><br>
<img src="../../images/drop_down_lines.gif"> <a href="javascript:PopNotes();" onMouseOver="window.status='';return true;">Show List</a><br>
<img src="../../images/drop_down_lines.gif"> <a href="./acc_main.jsp?my_home=<%=WI.fillTextValue("my_home")%>" target="organizermainFrame" onMouseOver="window.status='';return true;">Accomplishments</a><br>
</font></span>

<!--  <div> <img src="../../images/small_%20white_%20box.gif" width="7" height="7" border="0" >
  <strong><font color="#FFFFFF"><a href="../enrollment/subjects/subj_sectioning.jsp" target="enrolmainFrame">SUBJECT
  SECTIONING</a> </font></strong></div>-->
<%}if(bolGrantAll || vAuthList.indexOf("EVENTS") != -1 || bolMyHome){isAuthorized=true;%>
<div class="trigger" onClick="showBranch('branch2');swapFolder('folder2')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder2"> 
<strong><font color="#FFFFFF">EVENTS </font></strong></div>
<span class="branch" id="branch2"> <font color="#FFFFFF"> 
<img src="../../images/drop_down_lines.gif"> <a href="./event_entry.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;">Event Entry</a><br>
<img src="../../images/drop_down_lines.gif"><a href="./event_day.jsp?my_home=<%=WI.fillTextValue("my_home")%>" target="organizermainFrame" onMouseOver="window.status='';return true;">View Daily Events</a><br>
<img src="../../images/drop_down_lines.gif"><a href="./event_week.jsp?my_home=<%=WI.fillTextValue("my_home")%>" target="organizermainFrame" onMouseOver="window.status='';return true;">View Weekly Events</a><br>
<img src="../../images/drop_down_lines.gif"><a href="./event_month.jsp?my_home=<%=WI.fillTextValue("my_home")%>" target="organizermainFrame" onMouseOver="window.status='';return true;">View Monthly Events</a><br>
</font></span>

<%}if(bolGrantAll || vAuthList.indexOf("MESSAGE BOARD") != -1 || bolMyHome){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch3');swapFolder('folder3')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder3"> 
<strong><font color="#FFFFFF">MESSAGE BOARD</font></strong> 
&nbsp;&nbsp;&nbsp;<font size="1" color="#FFFFFF"><a href="javascript:document.form_.submit();">Click to refresh</a></font>
</div>
<span class="branch" id="branch3"> <font color="#FFFFFF">
<img src="../../images/drop_down_lines.gif"> <a href="./send_msg.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;"> Send Message</a><br>
<img src="../../images/drop_down_lines.gif"> <a href="./inbox_main.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;"> My Inbox <%if (vMsgBox != null && vMsgBox.size()>0){%>(<%=(String)vMsgBox.elementAt(3)%>)&nbsp;<%=(String)vMsgBox.elementAt(0)%><%}%></a><br>
<img src="../../images/drop_down_lines.gif"> <a href="./sent_msgs.jsp?viewAll=1&box_type=2" target="organizermainFrame" onMouseOver="window.status='';return true;"> My Outbox <%if (vMsgBox != null && vMsgBox.size()>0){%>(<%=(String)vMsgBox.elementAt(1)%>)<%}%></a><br>
<img src="../../images/drop_down_lines.gif"> <a href="./del_msgs.jsp?viewAll=1&box_type=0" target="organizermainFrame" onMouseOver="window.status='';return true;"> Trash <%if (vMsgBox != null && vMsgBox.size()>0){%>(<%=(String)vMsgBox.elementAt(2)%>)<%}%></a><br>
<img src="../../images/drop_down_lines.gif"> <a href="./inbox_settings.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;"> Inbox Settings</a><br>
</font></span>

<%}if(bolGrantAll || vAuthList.indexOf("FORUM") != -1 || bolMyHome){isAuthorized=true;%>

<div class="trigger" onClick="showBranch('branch5');swapFolder('folder5')"> 
<img src="../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder5"> 
<strong><font color="#FFFFFF">FORUM</font></strong></div>
<span class="branch" id="branch5"> <font color="#FFFFFF">
<img src="../../images/drop_down_lines.gif"> <a href="./forum_main.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;">Forum Main</a><br>
<%if(!bolMyHome){%>
<img src="../../images/drop_down_lines.gif"> <a href="./subcategory_maintenance.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;"> Category Maintenance</a><br>
<img src="../../images/drop_down_lines.gif"> <a href="./forum_mod_messages.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;">Moderator Messages</a><br>
<%if(bolGrantAll){%>
<img src="../../images/drop_down_lines.gif"> <a href="./mod_list.jsp" target="organizermainFrame" onMouseOver="window.status='';return true;"> Moderators</a><br>
<%}
}%>
</font></span>

<%}

if(strUserId == null)
	strErrMsg = "Session timeout. Please login again.";
else if(!isAuthorized)
	strErrMsg = "You are not authorized to view any link in this page. Please contact system admin for access permission.";
if(strErrMsg == null)
	strErrMsg = "";
%>
<font size="2" face="Verdana, Arial, Helvetica, sans-serif" color="#FFFFFF"><%=strErrMsg%></font>
	<input type="hidden" name="select_date">
	<input type="hidden" name="showCal" value="<%=request.getParameter("showCal")%>">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="is_parent" value="<%=WI.fillTextValue("is_parent")%>">
</form>
</body>
</html>
<%
if(dbOP != null) dbOP.cleanUP();
%>
