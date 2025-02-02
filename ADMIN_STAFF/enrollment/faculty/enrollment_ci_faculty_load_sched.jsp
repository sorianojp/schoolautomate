<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.show_list.value= "1";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewUpdateCI(){
	location = "./enrollment_ci_faculty_load_sched_new.jsp?emp_id="+escape(document.form_.emp_id.value)+
	"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+
	document.form_.semester[document.form_.semester.selectedIndex].value;
}

function PrintPage(){
 
	document.bgColor = "#FFFFFF"	
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	

	window.print();	
}
//all about ajax - to display student list with same name.
function AjaxMapName(e) {
		if(e.keyCode == 13) {
			ReloadPage();
			return;
		}
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING(CLINICAL SCHEDULE)"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load CI schedule","enrollment_ci_faculty_load_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"enrollment_faculty_ci_load_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
**/
//end of authenticaion code.

FacultyManagement FM = new FacultyManagement();
Vector vUserDetail = null;
Vector vRetResult = null;
Vector vRetCISched = null;


if ( WI.fillTextValue("show_list").compareTo("1") == 0) {
		strTemp = WI.fillTextValue("emp_id");
		
		if (strTemp.length() > 0)
		{
			strTemp = dbOP.mapOneToOther("USER_TABLE","ID_NUMBER","'" + strTemp+"'","user_index"," and is_del = 0");

			if ( strTemp != null) {
				vUserDetail = FM.viewFacultyDetail(dbOP,strTemp,WI.fillTextValue("sy_from"),
												WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
												
				if(vUserDetail == null)
					strErrMsg = FM.getErrMsg();
				else
				{
					vRetResult = FM.viewFacultyLoadDetail(dbOP,strTemp,WI.fillTextValue("sy_from"),
												WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
//					if(vRetResult == null) {
//						strErrMsg = FM.getErrMsg();
//					}
					
					vRetCISched = FM.operateOnFacultyLoadCI(dbOP,request,4);
//					if (vRetCISched	== null && strErrMsg == null ) 
//						strErrMsg = FM.getErrMsg();
				}
			}else{ 
				strErrMsg = " Please enter a valid faculty ID.";
			}
		}else{
			strErrMsg = " Please enter faculty ID.";
		}
	if(strErrMsg == null) strErrMsg = "";
}
%>

<form action="./enrollment_ci_faculty_load_sched.jsp" method="post" name="form_">
<% if (!WI.fillTextValue("hide_header").equals("1")){%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY PAGE - CLINICAL INSTRUCTOR LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="30" colspan="4"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td  width="14%" height="25">Academic Year</td>
      <td width="19%" height="25"> <%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';DisplaySYTo('form_','sy_from','sy_to')" onKeyUp="DisplaySYTo('form_','sy_from','sy_to')" value="<%=strTemp%>">
        to 
        <%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" id="sy_to" size="4" maxlength="4"  class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"
	   value="<%=strTemp%>" tabindex="-1"></td>
      <td width="6%">Term</td>
      <td width="59%"><select name="semester" onChange="ReloadPage()">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

		if(strTemp.equals("2"))
		 {%>
          <option value="2" selected> 2nd Sem</option>
          <%}else{%>
          <option value="2"> 2nd Sem</option>
          <%} if (strTemp.equals("3")){%>
          <option value="3" selected> 3rd Sem</option>
          <%}else{%>
          <option value="3"> 3nd Sem</option>
          <%} if (strTemp.equals("0")){%>
          <option value="0" selected> Summer</option>
          <%}else{%>
          <option value="0"> Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Employee ID </td>
      <td height="25"><input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="32" value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName(event);">      </td>
      <td height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td height="25"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr >
      <td></td>
      <td colspan="4"><label id="coa_info"></label></td>
    </tr>
<%}%> 	
  </table>
<% if (vUserDetail != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="mid_level">
  
<% if (!WI.fillTextValue("hide_header").equals("1")){%>   
    <tr> 
      <td  colspan="2" height="15"><hr size="1"></td>
    </tr>
<%}else{%>
    <tr>
      <td height="25" colspan="2"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong> <br>
	  <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
 	  <font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></td>
    </tr>
<%}%> 
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Employee Name : <%=(String)vUserDetail.elementAt(1)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> College : <%=(String)vUserDetail.elementAt(4)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td > Position : <%=(String)vUserDetail.elementAt(7)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Employment Status : <%=(String)vUserDetail.elementAt(2)%></td>
    </tr>
<% if (!WI.fillTextValue("hide_header").equals("1")) {%> 
    <tr> 
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;
	  <a href="javascript:ViewUpdateCI()"><img src="../../../images/update.gif" alt="Set Cl Schedule" width="60" height="26" border="0"></a>
        click to update Clinical Instructor Load Schedule      </td>
    </tr>
<%}%> 	
  </table>  

<%
} // end vUserDetail != null

if(vRetResult != null)
{

%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EBD6E6"> 
      <td height="25" colspan="7" align="center" bgcolor="#FFE6E7" class="thinborder"><strong><font color="#0000FF">FACULTY LOAD/SCHEDULE 
        DETAIL</font></strong></td>
    </tr>
    <tr> 
      <td align="center" class="thinborder"><strong>MONDAY</strong></td>
      <td align="center" class="thinborder"><strong>TUESDAY</strong></td>
      <td align="center" class="thinborder"><strong>WEDNESDAY</strong></td>
      <td align="center" class="thinborder"><strong>THURSDAY</strong></td>
      <td align="center" class="thinborder"><strong>FRIDAY</strong></td>
      <td height="25" align="center" class="thinborder"><strong>SATURDAY</strong></td>
      <td align="center" class="thinborder"><strong>SUNDAY</strong></td>
    </tr>
    <%
	String[] convertAMPM={" AM"," PM"};//System.out.println(vRetResult);
for(int i = 0; i< vRetResult.size();){%>
    <tr> 
      <%strTemp = "";
		  while( vRetResult.size() > 0 && ((String)vRetResult.elementAt(i)).compareTo("1") ==0) //this is monday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
		  			(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td height="25" align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%strTemp = "";
		  while( vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("2") ==0) //this is Tuesday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
		  			(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("3") ==0) //this is Wednesday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("4") ==0) //this is Thursday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("5") ==0) //this is Friday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("6") ==0) //this is Saturday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("0") ==0) //this is Sunday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room:"+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj :"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
    <%
	//i = i+9;
	}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="body_2">
    <tr>
      <td height="20">&nbsp;</td>
    </tr>
 </table>
<%
  } // only if show list is shown.

if (vRetCISched != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EBD6E6"> 
      <td height="25" colspan="6" align="center" bgcolor="#FFE6E7" class="thinborder"><strong><font color="#0000FF">CLINICAL 
        INSTRUCTOR LOAD SCHEDULE </font></strong></td>
    </tr>
    <tr> 
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>SUBJECT</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="21%" align="center" class="thinborder"><font size="1"><strong>HOSPITAL/CLINIC 
        NAME<br>
        ADDRESS</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong> 
        AREA OF ASSIGNMENT</strong></font></td>
      <td width="10%" height="27" align="center" class="thinborder"><font size="1"><strong>DURATION</strong></font></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">INCLUSIVE 
        DATES </font></strong></td>
    </tr>
    <%  String[] astrConvType ={" Hour(s)"," Day(s)"," Week(s)"," Month(s)"};
		for (int i = 1; i < vRetCISched.size(); i+=15) {%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetCISched.elementAt(i+11)%> &nbsp;(<%=(String)vRetCISched.elementAt(i+13)%>)</td>
      <%
	 	strTemp = WI.getStrValue((String)vRetCISched.elementAt(i+2));
		if (strTemp.length() > 0) {
			strTemp +=  WI.getStrValue((String)vRetCISched.elementAt(i+3)," :: ","","");
		}else{
			strTemp = WI.getStrValue((String)vRetCISched.elementAt(i+3));
		}
	 %>
      <td class="thinborder">&nbsp; <%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetCISched.elementAt(i+8)%><br> &nbsp;<%=(String)vRetCISched.elementAt(i+9)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetCISched.elementAt(i+10)%></td>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetCISched.elementAt(i+4),"",astrConvType[Integer.parseInt((String)vRetCISched.elementAt(i+5))],"&nbsp;")%> </td>
      <td class="thinborder">&nbsp;
        <%
		strTemp = WI.getStrValue((String)vRetCISched.elementAt(i+6));
		if (strTemp.length() > 0) {
			strTemp +=  WI.getStrValue((String)vRetCISched.elementAt(i+7)," to ","","");
		}else{
			strTemp = WI.getStrValue((String)vRetCISched.elementAt(i+7));
		}
	%>
        <%=strTemp%> </td>
    </tr>
    <%} // end for loop%>
  </table>
<%
  } // vRetCISched != null
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr >
      <td height="25" colspan="2" align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" alt="print faculty schedule" width="58" height="26" border="0"></a><span class="style1">click to print page </span></td>
    </tr>
    <tr >
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" >&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="show_list" value="0"> 
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
