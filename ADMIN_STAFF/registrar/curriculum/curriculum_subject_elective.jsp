<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	this.SubmitOnce('subm');
}
function CancelRecord()
{
	document.subm.page_action.value = "";
	this.SubmitOnce('subm');
}

function AddRecord()
{
	if(document.subm.page_action.value=="")
		document.subm.page_action.value = "1";
	this.SubmitOnce('subm');
}
function DeleteRecord(strTargetIndex)
{
	document.subm.page_action.value = "0";
	document.subm.info_index.value = strTargetIndex;

	this.SubmitOnce('subm');
}
function EditRecord(strTargetIndex,strElectiveName)
{
	document.subm.page_action.value = "2";
	document.subm.info_index.value = strTargetIndex;
	document.subm.elective_name.value = strElectiveName;
	document.addImage.src="../../../images/edit.gif";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	String strGoToPage = request.getParameter("hist");
	if(strGoToPage == null || strGoToPage.trim().length() == 0)
		strGoToPage = "./curriculum_subject.jsp";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance -subject Elective subject","curriculum_subject_elective.jsp");
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
														"curriculum_subject_elective.jsp");
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


//get subject index of the subject to be tagged.
String strSubjectIndex = request.getParameter("sub_index");
boolean bolProceed = true;

if(strSubjectIndex == null || strSubjectIndex.trim().length() ==0)
{
	strTemp = " and is_del=0 and SUB_CODE='"+ConversionTable.replaceString(request.getParameter("sub_code"),"'","''")+
			"' and sub_name='"+ConversionTable.replaceString(request.getParameter("sub_name"),"'","''")+"'";

	strSubjectIndex = dbOP.mapOneToOther("SUBJECT","CATG_INDEX",request.getParameter("catg_index"),"SUB_INDEX",strTemp);
}
if(strSubjectIndex == null || strSubjectIndex.trim().length() == 0)
{
	strErrMsg = "can't locate subject code/subject name and category. Please create before assigning elective subject.";
	bolProceed = false;
}

//end of security code.
CurriculumSM SM = new CurriculumSM();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(SM.manageElective(dbOP,request,strSubjectIndex,1) != null)
		strErrMsg = "Elective subject added successfully.";
	else
		strErrMsg = SM.getErrMsg();
}
else if(strTemp.compareTo("2") == 0)//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	if(SM.manageElective(dbOP,request,strSubjectIndex,2) != null)
		strErrMsg = "Elective subject edited successfully.";
	else
		strErrMsg = SM.getErrMsg();
}
else if(strTemp.compareTo("0") == 0)//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	if(SM.manageElective(dbOP,request,strSubjectIndex,0) != null)
		strErrMsg = "Elective subject deleted successfully.";
	else
		strErrMsg = SM.getErrMsg();
}

//get all levels created.
Vector vRetResult = new Vector();
vRetResult = SM.manageElective(dbOP,request,strSubjectIndex,3);

//get subject code drop down list.
Vector vLoadSubCode = SM.loadSubjectCode(dbOP,null,strSubjectIndex);
if(vLoadSubCode == null)
{
	bolProceed = false;
	strErrMsg = SM.getErrMsg();
}
else if(vLoadSubCode.size() == 0)
{
	bolProceed = false;
	strErrMsg = "No other subject list found. Please check subject category.";
}
if(!bolProceed)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

%>

<form name="subm" method="post" action="./curriculum_subject_elective.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SUBJECT MAINTENANCE - ELECTIVE SUBJECT OPTIONS MAINTENANCE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25"><font color="#FFFFFF">&nbsp;</font></td>
      <td height="25"><a href="curriculum_subject.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="20%" height="25">&nbsp;</td>
      <td width="34%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="44%" height="25">Subject code : <strong><%=request.getParameter("sub_code")%></strong></td>
      <td height="25" colspan="2">Subject category : <strong><%=request.getParameter("catg_name")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Subject Title : <strong><%=request.getParameter("sub_name")%></strong></td>
      <td colspan="2" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
	</table>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="15%">Elective </td>
      <td width="83%"><input type="text" name="scroll_sub" size="12" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','elec_sub_index',true,'subm');"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="elec_sub_index"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="0">Select Any</option>
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as scode"," from subject where IS_DEL=0 and sub_index <> "+strSubjectIndex+
				" order by scode asc", WI.fillTextValue("elec_sub_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%if(iAccessLevel > 1){%> <a href="javascript:AddRecord();"><img name="addImage" src="../../../images/add.gif" border="0"></a> 
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to save 
        entry</font> &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to cancel</font> 
        <%}else{%>
        Not authorized to add/edit/delete 
        <%}%> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">&nbsp;</td>
    </tr>
    <%
    if(strErrMsg != null)
    {%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}//this shows the edit/add/delete success info
%>
  </table>
<table width=100% border=0 bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">

    <tr bgcolor="#B9B292">
      <td height="25"class="thinborderTOPLEFTRIGHT"><div align="center">LIST OF EXISTING ELECTIVE SUBJECTS
          FOR : <%=request.getParameter("sub_name").toUpperCase()%></div></td>
    </tr>
	</table>
<%
if(vRetResult != null && vRetResult.size() >0)//3 in one set ;-)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="36%" height="25" class="thinborder"><div align="center"><font size="1"><strong>ELECTIVE 
          SUBJECT CODE</strong></font></div></td>
      <td width="37%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr> 
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%> </td>
    </tr>
    <%
i = i+2;
}//end of loop %>
  </table>

<%}//end of displaying %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
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
<input type="hidden" name="page_action">

<input type="hidden" name="sub_code" value="<%=request.getParameter("sub_code")%>">
<input type="hidden" name="sub_name" value="<%=request.getParameter("sub_name")%>">
<input type="hidden" name="catg_index" value="<%=request.getParameter("catg_index")%>">
<input type="hidden" name="catg_name" value="<%=request.getParameter("catg_name")%>">
<input type="hidden" name="sub_index" value="<%=strSubjectIndex%>">
<input type="hidden" name="viewall" value="<%=request.getParameter("viewall")%>">
<input type="hidden" name="hist" value="<%=request.getParameter("hist")%>">


<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
