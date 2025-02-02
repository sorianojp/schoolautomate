<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Disable(strDisable) {
	document.subm.disable_pr.value = strDisable;
	this.SubmitOnce('subm');
}
function ReloadPage()
{
	document.subm.disable_pr.value = "";
	this.SubmitOnce('subm');
}
function CancelRecord()
{
	location="./curriculum_subject_pre.jsp";
}

function AddRecord()
{
	document.subm.deleteRecord.value = 0;
	document.subm.addRecord.value = 1;

	this.ReloadPage();
}

function DeleteRecord(strTargetIndex)
{
	document.subm.deleteRecord.value = 1;
	document.subm.addRecord.value = 0;
	document.subm.info_index.value = strTargetIndex;

	this.ReloadPage();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	String strGoToPage = request.getParameter("hist");
	if(strGoToPage == null || strGoToPage.trim().length() == 0)
		strGoToPage = "./curriculum_subject.jsp";
	
	boolean bolViewAll = true;
	boolean bolIsPRDisabled = false;//if pre-requisite is disabled, i have to show the pre-requisite in grey.
	String strPRDisabledColor = null; 
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance -subject pre-requisite","curriculum_subject_pre.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_subject_pre.jsp");
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

//end of authenticaion code.

CurriculumSM SM = new CurriculumSM();
if(WI.fillTextValue("disable_pr").length() > 0) {
	boolean bolEnable = false;
	if(WI.fillTextValue("disable_pr").compareTo("0") ==0)
		bolEnable = true;
	SM.enableDisablePreq(dbOP, WI.fillTextValue("sub_index"),bolEnable);
	strErrMsg = SM.getErrMsg();
}
//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(SM.addPRequisite(dbOP,request))
	{
		strErrMsg = "Successfully Added.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SM.getErrMsg()%></font></p>
		<%
		return;
	}
}
else//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("deleteRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(SM.deletePRequisite(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
		{
			strErrMsg = "Successfully Removed";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=SM.getErrMsg()%></font></p>
			<%
			return;
		}
	}
}

//get subject index of the subject to be tagged.
String strSubjectIndex = request.getParameter("sub_index");
boolean bolProceed = true;

String strSubCode  = request.getParameter("sub_code");
String strSubName  = request.getParameter("sub_name");
String strCatgName = request.getParameter("catg_name");


//I have to get now those three info.. 

if(strSubjectIndex == null || strSubjectIndex.trim().length() ==0)
{
	strTemp = " and is_del=0 and SUB_CODE='"+ConversionTable.replaceString(strSubCode,"'","''")+
			"' and sub_name='"+ConversionTable.replaceString(strSubName,"'","''")+"'";
	//System.out.println(strTemp);
	strSubjectIndex = dbOP.mapOneToOther("SUBJECT","CATG_INDEX",request.getParameter("catg_index"),"SUB_INDEX",strTemp);
}
if(strSubjectIndex == null || strSubjectIndex.trim().length() == 0)
{
	strErrMsg = "can't locate subject code/subject name and category. Please create before assigning pre-requisites.";
	bolProceed = false;
}
else {//check pre-requisite.

	if(strSubCode == null) {
		java.sql.ResultSet rs = dbOP.executeQuery("select sub_code, sub_name from subject where sub_index = "+strSubjectIndex);
		if(rs.next()) {
			strSubCode = rs.getString(1);
			strSubName = rs.getString(2);
		}
		rs.close();
	}
	bolIsPRDisabled = SM.checkIfSubPreqIsDisabled(dbOP, strSubjectIndex);
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolShowEnablePreReq = true;
if(strSchCode.startsWith("EAC") || strSchCode.startsWith("NEU") ) {
	bolShowEnablePreReq = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
}



//get all levels created.
Vector vRetResult = new Vector();
vRetResult = SM.viewAllRequisite(dbOP,strSubjectIndex);

if(vRetResult ==null)
{
	bolProceed = false;
	strErrMsg = SM.getErrMsg();
}
//get subject code drop down list.
/** call load combo.
Vector vLoadSubCode = SM.loadSubjectCode(dbOP,null,strSubjectIndex);
if(vLoadSubCode == null)
{
	bolProceed = false;
	strErrMsg = SM.getErrMsg();
}
else if(vLoadSubCode.size() == 0)
{
	bolProceed = false;
	strErrMsg = "No subject list found. Pre-requisite can't be created.";
}
**/
if(!bolProceed)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

%>

<form name="subm" method="post" action="./curriculum_subject_pre.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SUBJECT PRE-REQUISITE MAINTENANCE ::::</strong></font><font color="#FFFFFF"></font></div></td>
    </tr>
    <tr> 
      <td height="25"><font color="#FFFFFF">&nbsp;</font></td>
      <td height="25"><a href="<%=strGoToPage%>"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="15%" height="25">&nbsp;</td>
      <td width="39%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="44%" height="25">Subject code : <strong><%=strSubCode%></strong></td>
      <td height="25" colspan="2">Subject category : <strong><%=request.getParameter("catg_name")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Subject Title : <strong><%=strSubName%></strong></td>
      <td colspan="2" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <%
 if(request.getParameter("viewall") == null ||  request.getParameter("viewall").compareTo("1") != 0)
 {
 bolViewAll = false;
 %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong>To filter SUBJECT display enter subject 
        code starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:15px">
        and click <font size="1"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font color="#0000FF">Pre-requisite subject(s):</font>
        <font size="1">
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','pr_sub_index',true,'subm');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> 
        <!--Subject code : 
               <select name="pr_sub_index" onChange="ReloadPage();">
          <option value="0">N/A</option>
          <%
//strTemp =  request.getParameter("pr_sub_index");
//if(strTemp == null) strTemp="";
//for(int i = 0 ; i<vLoadSubCode.size(); ++i)
//{
//	if( ((String)vLoadSubCode.elementAt(i)).compareTo(strTemp) == 0)
//	{%>
          <option value="<%//=(String)vLoadSubCode.elementAt(i)%>" selected> 
          <%//=(String)vLoadSubCode.elementAt(++i)%></option>
          <%//}else{%>
          <option value="<%//=(String)vLoadSubCode.elementAt(i)%>"> 
          <%//=(String)vLoadSubCode.elementAt(++i)%></option>
          <%//}%>
          <%//}%>
        </select>
-->
        
        <select name="pr_sub_index" style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("sub_index","sub_code +' &nbsp;&nbsp;&nbsp;('+sub_name+')'"," from subject where IS_DEL=0 and sub_index <> "+strSubjectIndex+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", WI.fillTextValue("pr_sub_index"), false)%> 
        </select>      </td>
      <%
strTemp = dbOP.mapOneToOther("SUBJECT", "SUB_INDEX",request.getParameter("pr_sub_index"), "SUB_NAME", " and is_del=0");
if(strTemp == null) strTemp = "";
%>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font color="#0000FF">Pre-requisite year level 
        standing:
          <select name="year_level">
            <option value="0">N/A</option>
            <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") == 0){%>
            <option selected value="1">1st</option>
            <%}else{%>
            <option value="1">1st</option>
            <%}if(strTemp.compareTo("2") ==0){%>
            <option selected value="2">2nd</option>
            <%}else{%>
            <option value="2">2nd</option>
            <%}if(strTemp.compareTo("3") ==0){%>
            <option selected value="3">3rd</option>
            <%}else{%>
            <option value="3">3rd</option>
            <%}if(strTemp.compareTo("4") ==0){%>
            <option selected value="4">4th</option>
            <%}else{%>
            <option value="4">4th</option>
            <%}if(strTemp.compareTo("5") ==0){%>
            <option selected value="5">5th</option>
            <%}else{%>
            <option value="5">5th</option>
            <%}if(strTemp.compareTo("6") ==0){%>
            <option selected value="6">6th</option>
            <%}else{%>
            <option value="6">6th</option>
            <%}%>
          </select>
      </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" style="font-size:11px; color:#0000FF; font-weight:bold"><input type="checkbox" name="is_coreq" value="1"> Is Co-Requisite?</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to save entry </font></td>
    </tr>
    <%}//if iAcccessLevel > 1
if(vRetResult != null && vRetResult.size() >0 && iAccessLevel ==2 && bolShowEnablePreReq)//6 in one set ;-)
{//show enable/ disable only if there are pre-requisite results.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><div align="right">Pre-requisite checking status 
          :&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
      <td height="25"> <%
if(bolIsPRDisabled){%> <a href="javascript:Disable(0);"><img src="../../../images/enable.gif" border="0"></a> 
        <font color="#0000FF" size="1">click to enable pre-requisites</font> <%}else{%> <a href="javascript:Disable(1);"><img src="../../../images/disable.gif" border="0"></a> 
        <font color="#0000FF" size="1">click to disable pre-requisites</font> 
        <%}%> </td>
      <%}//end of showing the enable or disable button.
%>
    </tr>
    <%
    if(strErrMsg != null)
    {%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}//this shows the edit/add/delete success info
}//this displays the add feature if viewall parameter is not set.%>
  </table>
<table width=100% border=0 bgcolor="#FFFFFF">

    <tr bgcolor="#B9B292">
      <td height="25" ><div align="center">EXISTING PRE-REQUISITE SUBJECTS FOR
          : <%=strSubCode.toUpperCase()%></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="23%" height="25" align="center"><font size="1"><strong>SUBJECT
        CODE </strong></font></td>
      <td width="56%" align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>Is Co-Requisite</strong></font></td>
      <td width="9%" align="center"><font size="1"><B>DELETE</B></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{
	if(WI.getStrValue(vRetResult.elementAt(i+1)).length() ==0) {
		i = i+5;
		continue;
	}
	if(vRetResult.elementAt(i + 4).equals("1"))
		strTemp = "<img src='../../../images/tick.gif'>";
	else	
		strTemp = "&nbsp;";
	
	if(vRetResult.elementAt(i + 5).equals("1"))
		strPRDisabledColor="<font color=red>";
	else		
		strPRDisabledColor = "<font>";
%>
    <tr>
      <td align="center" height="25"><%=strPRDisabledColor%><%=WI.getStrValue(vRetResult.elementAt(i+1),"&nbsp;")%></font></td>
      <td align="center"><%=strPRDisabledColor%><%=WI.getStrValue(vRetResult.elementAt(i+2),"&nbsp;")%></font></td>
      <td align="center"><%=strTemp%></td>
      <td align="center">
        <%
	  if(!bolViewAll && iAccessLevel ==2)//only if view all is not true, allow delete
	  {%>
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        N/A
        <%}%>      </td>
    </tr>
    <%
i = i+5;
}//end of loop

//display the first pre-requisite here.
boolean bolIsPreRequisite = false;
String strDeleteLink = "&nbsp;";
for(int i = 0 ; i< vRetResult.size(); ++i)
{
	if( vRetResult.elementAt(i+3) == null || ((String)vRetResult.elementAt(i+3)).compareTo("N/A") ==0)
	{
		i = i+5;
		continue;
	}
	strTemp = (String)vRetResult.elementAt(i+3);
	//add delete link only if it is not having a subject pre-requisite - this is only for pre-requisite having year level only.
	if( vRetResult.elementAt(i+1) == null) //no reference subject.
		strDeleteLink = "<a href='javascript:DeleteRecord(\""+(String)vRetResult.elementAt(i)+"\")'><img src=\"../../../images/delete.gif\" border=\"0\"></a>";
	bolIsPreRequisite = true;


	if(vRetResult.elementAt(i + 5).equals("1"))
		strPRDisabledColor="<font color=red>";
	else		
		strPRDisabledColor = "<font>";

	break;
}
if(bolIsPreRequisite){
%>
<tr>
      <td height="25" colspan="3"><strong><%=strPRDisabledColor%>Pre-requisite year level standing:</strong>
        <%=strTemp%></font></td>
      <td align="center"><%=strDeleteLink%></td>
    </tr>
<% }//if bolPrerequisite
%>
  </table>

<%}//end of displaying %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<!-- all hidden fields go here -->
<%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="deleteRecord" value="0">

<input type="hidden" name="sub_code" value="<%=strSubCode%>">
<input type="hidden" name="sub_name" value="<%=strSubName%>">
<input type="hidden" name="catg_index" value="<%=request.getParameter("catg_index")%>">
<input type="hidden" name="catg_name" value="<%=request.getParameter("catg_name")%>">
<input type="hidden" name="sub_index" value="<%=strSubjectIndex%>">
<input type="hidden" name="viewall" value="<%=request.getParameter("viewall")%>">
<input type="hidden" name="hist" value="<%=request.getParameter("hist")%>">
<input type="hidden" name="disable_pr">


<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
