<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if(WI.fillTextValue("my_home").compareTo("1") == 0 ){
		bolMyHome = true;
	}
	String strSchCode =	WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");

		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

//		alert ("helloe world");

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}


function viewMandatoryTrainings(){
	var pgLoc = "./mandatory_trainings.jsp";
	var win=window.open(pgLoc,"UpdateWindow",'dependent=yes,width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}



function ReloadPage(){
	this.SubmitOnce("form_");
}

function AddRecord(){

//	for (var i = 0; i < Number(document.form_.max_display.value);i++){
//		if (eval("document.form_.checkbox"+i+".checked")){
//			alert (eval("document.form_.training_" + i +
//						"[document.form_.training_"+i+".selectedIndex].value"))
//		}
//	}

	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("form_");
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	this.SubmitOnce("form_");
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Request Training","training_attendance.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","TRAINING MANAGEMENT",request.getRemoteAddr(),
												"training_attendance.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

Vector vRetResult = null;
Vector vEditInfo = null;
Vector vFinalResult = null;

int iAction =  Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));
String strPrepareToEdit =  WI.fillTextValue("prepareToEdit");
hr.HRMandatoryTrng  mt = new hr.HRMandatoryTrng();


if (iAction == 0){
	if (mt.operateOnTrngAttendance(dbOP, request,0) != null){
		strErrMsg= " Personnel Attendance removed successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}else if ( iAction == 1){


	if (mt.operateOnTrngAttendance(dbOP, request,1) != null){
		strErrMsg= " Personnel Attendance recorded successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}


	Vector vTemp = null;
	vRetResult = mt.operateOnRequireTraining(dbOP, request,7);
	//System.out.println(mt.getErrMsg());

	if (vRetResult != null && vRetResult.size()> 0){
		vTemp = (Vector)vRetResult.remove(0);
	}

	vFinalResult  = mt.operateOnTrngAttendance(dbOP, request,4);

%>
<body bgcolor="#663300"  class="bgDynamic">
<form action="./training_attendance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: SET MANDATORY TRAINING FOR PERSONNEL ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<% if (!WI.fillTextValue("view_5").equals("1")) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="17%" height="30">TYPE OF TRAINING </td>
 	  <td width="79%" height="30">
        <select name="training_type_index" onChange="ReloadPage()">
          <option value="">Select Training Type</option>
          <%=dbOP.loadCombo("TRAINING_TYPE_INDEX","TRAINING_TYPE"," FROM HR_PRELOAD_TRAINING_TYPE order by TRAINING_TYPE",WI.fillTextValue("training_type_index"),false)%>
        </select><font size="1">(optional, filter only)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="29%" height="30" valign="bottom">TRAINING NAME / DESCRIPTION :</td>
      <td width="67%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="2"><strong>
        <select name="mand_training_index" onChange="ReloadPage()" >
          <option value="">Select Training Name</option>
          <%=dbOP.loadCombo("MAND_TRAINING_INDEX","MAND_TRAINING_NAME",
	  				" FROM hr_mand_training_name where is_valid = 1 and is_del = 0 " +
					WI.getStrValue(request.getParameter("training_type_index"),
					"and  TRAINING_TYPE_INDEX = ","","") +
					" order by MAND_TRAINING_NAME",WI.fillTextValue("mand_training_index"),false)%>
        </select>
      </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="13%" height="41">Employee ID </td>
      <td width="18%" height="41">
	 <% if (!bolMyHome) {%>
	  <input name="emp_id" type="text" class="textbox" size="16"
	  	onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AjaxMapName(1);"
		value="<%=WI.fillTextValue("emp_id")%>" onBlur="style.backgroundColor='white'" >
	<%}else{%>
	<font size="3" color="#FF0000"><strong>
		<%=(String)request.getSession(false).getAttribute("userId")%> </strong></font>
	  <input name="emp_id" type="hidden"
	  		value="<%=(String)request.getSession(false).getAttribute("userId")%>">
	<%}%>
		</td>
      <td width="65%"><label id="coa_info"></label></td>
    </tr>
  </table>

<%} // if not view old..
 if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">


    <tr bgcolor="#DBEEE0">
	<% if (bolMyHome){
			strTemp = " MANDATORY TRAINING FOR : "
						+ (String)request.getSession(false).getAttribute("userId");
		}else{
			strTemp = "LIST OF PERSONNEL WITH MANDATORY TRAINING";
		}
	%>
      <td height="25" colspan="4" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
    <% 	String strCurrentTrainingIndex = "";
		int iCtr = 0;
		String strSelectListLeft = "";
		String strSelectListRight = "";
		int k = 0;
		for (int i=0 ; i < vRetResult.size(); i+= 7, iCtr++){


		if(!strCurrentTrainingIndex.equals((String)vRetResult.elementAt(i+4))){
			strCurrentTrainingIndex =(String)vRetResult.elementAt(i+4);
			strTemp ="";
			strSelectListLeft = "";
			strSelectListRight = "";


			if (vTemp != null && vTemp.size()> 0){
				while (k < vTemp.size() &&
							strCurrentTrainingIndex.equals((String)vTemp.elementAt(k))){
					if (strSelectListLeft.length() == 0){
						strSelectListLeft = "<select name=\"training_sched_index";
						strSelectListRight += "\">" +
							"<option value=\""+(String)vTemp.elementAt(k+1)+"\">"+
							(String) vTemp.elementAt(k+2) + " :: " +
							(String) vTemp.elementAt(k+3) +
							"</option>";
					}else{
						strSelectListRight +=
							"<option value=\""+(String)vTemp.elementAt(k+1)+"\">"+
							(String) vTemp.elementAt(k+2) + " :: " +
							(String) vTemp.elementAt(k+3) +
							"</option>";
					}

					k+= 4;
				}

				if (strSelectListLeft.length() > 0)
					strSelectListRight += "</select>";
			}
	%>
    <tr>
      <td height="25" colspan="4" bgcolor="#EEF2F9" class="thinborder">
	  <strong>TYPE / NAME OF TRAINING :
	  	<font color="#0000FF"><%=(String)vRetResult.elementAt(i+5)%></font></strong></td>
    </tr>
	<%}%>
    <tr>
      <td width="6%" height="25" class="thinborder">&nbsp;
	  <input type="hidden" value="<%=(String)vRetResult.elementAt(i)%>"
	  		name="training_index<%=iCtr%>">	  </td>
      <td width="32%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),
  					(String)vRetResult.elementAt(i+2) + " : " + (String)vRetResult.elementAt(i+3))%>
	  <input type="hidden" value="<%=(String)vRetResult.elementAt(i+6)%>" name="user_index<%=iCtr%>">	  </td>
	  <%  strTemp = "";
		  if (strSelectListLeft.length() > 0)
		  	strTemp = strSelectListLeft + iCtr +strSelectListRight; %>

      <td width="57%" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"No Schedule")%></td>
      <td width="5%" class="thinborder">&nbsp;
	  <% if (!bolMyHome && strTemp.length() > 0){%>
		  <input type="checkbox" value="1" name="checkbox<%=iCtr%>">
	 <%}%>

	  </td>
    </tr>
    <%}%>
  </table>

 <input type="hidden" name="max_display" value="<%=iCtr%>">

<% if (!bolMyHome) {%>
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2" align="center">
        <% if (iAccessLevel > 1){%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1">click to save selected entries</font>
        <%} // end iAccessLevel  > 1%></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
  } // save not allowed for my home
} //vRetResult != null && vRetResult.size() > 0

 if (vFinalResult != null && vFinalResult.size() > 0) {
%>
<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBEEE0">
	<% if (bolMyHome){
			strTemp = " MANDATORY TRAINING ATTENDED BY : "
						+ (String)request.getSession(false).getAttribute("userId");
		}else{
			strTemp = "PERSONNEL MANDATORY  TRAINING ATTENDANCE";
		}
	%>
      <td height="25" colspan="4" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
    </tr>
    <% 	String strCurrentTrainingIndex = "";
		for (int i=0 ; i < vFinalResult.size(); i+= 6){
			if(!strCurrentTrainingIndex.equals((String)vFinalResult.elementAt(i+3))){
				strCurrentTrainingIndex =(String)vFinalResult.elementAt(i+3);
	%>
    <tr>
      <td height="25" colspan="4" bgcolor="#EEF2F9" class="thinborder">
	  <strong>TYPE / NAME OF TRAINING :
	  	<font color="#0000FF"><%=strCurrentTrainingIndex%></font></strong></td>
    </tr>
	<%}%>
    <tr>
      <td width="3%" height="25" class="thinborder">&nbsp; </td>
      <td width="34%" class="thinborder">
	  		<%=(String)vFinalResult.elementAt(i+1) + " : " + (String)vFinalResult.elementAt(i+2)%>	   </td>
	  <%
		strTemp ="";
		if ((String)vFinalResult.elementAt(i+5) != null)
			strTemp =(String)vFinalResult.elementAt(i+5);
		if ((String)vFinalResult.elementAt(i+4) != null)
			strTemp +="<br>::: "  + (String)vFinalResult.elementAt(i+4);
	  %>
      <td width="56%" class="thinborder">&nbsp;<%=strTemp%></td>
      <td width="7%" class="thinborder"><%  if ( iAccessLevel == 2 && !bolMyHome) {%>
		<a href="javascript:DeleteRecord(<%=(String)vFinalResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%> NA <%}%> </td>
    </tr>
    <%}%>
  </table>
<%} // if vFinalResult != null) %>




<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

