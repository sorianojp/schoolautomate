<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="Javascript">

//This script is added to swap image.

var isEdit=0;//set to 1 when edit is clicked.
var iscancelEdit = 0; file://set to 1 when cancel is clicked.

function editon()
{
	document.imgAdd.src="../../../images/save.gif";
	document.imgCancel.src="../../../images/cancel.gif";
}
function editoff()
{
	if(isEdit == 1) return;
	document.imgAdd.src="../../../images/add.gif";
	   document.imgCancel.src="../../../images/blank.gif";
}
function cancelon()
{
	if(isEdit == 0) return;
		document.imgAdd.src="../../../images/add.gif";

}
function canceloff()
{
	if(isEdit == 0) return;
	document.imgAdd.src="../../../images/save.gif";
}

function editClicked()//this is when edit button is clicked.
{
	isEdit = 1;
	iscancelEdit = 0;
}
function cancelClicked()//this is called when cancel is clicked.
{
	isEdit = 0;
	iscancelEdit = 1;
	document.imgCancel.src="../../../images/blank.gif";

	document.cmajor.major_name.value = "";
	document.cmajor.major_course_code.value = "";
	document.cmajor.editRecord.value = 0;
	document.cmajor.deleteRecord.value = 0;
	document.cmajor.addRecord.value = 0;
	document.cmajor.prepareToEdit.value = 0;
	//document.cmajor.reload();
}
///////////////////// END OF scRIPT TO SWAP IMAGE FOR EDIT/ADD/CANCEL //////////////////////////////////////////////
function PrepareToEdit(strInfoIndex, strMajorName,strCourseCode)
{
	document.cmajor.editRecord.value = 0;
	document.cmajor.deleteRecord.value = 0;
	document.cmajor.addRecord.value = 0;
	document.cmajor.prepareToEdit.value = 1;

	document.cmajor.info_index.value = strInfoIndex;
	document.cmajor.major_name.value = strMajorName;
	document.cmajor.major_course_code.value = strCourseCode;
	
	//document.getElementById("notoffered").innerHTML = '';
}
function AddRecord()
{
	if(document.cmajor.prepareToEdit.value == 1)
	{
		EditRecord(document.cmajor.info_index.value);
		return;
	}
	document.cmajor.editRecord.value = 0;
	document.cmajor.deleteRecord.value = 0;
	document.cmajor.addRecord.value = 1;

	document.cmajor.submit();
}
function EditRecord(strTargetIndex)
{
	document.cmajor.editRecord.value = 1;
	document.cmajor.deleteRecord.value = 0;
	document.cmajor.addRecord.value = 0;
	document.cmajor.info_index.value = strTargetIndex;

	document.cmajor.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.cmajor.editRecord.value = 0;
	document.cmajor.deleteRecord.value = 1;
	document.cmajor.addRecord.value = 0;

	document.cmajor.info_index.value = strTargetIndex;
	document.cmajor.prepareToEdit.value == 0;

	document.cmajor.submit();
}

function GoBack()
{
	location = "./curriculum_course_edit.jsp?info_index="+document.cmajor.caller_info_index.value;
}
var iRadioClicked = -1;
function ButtonClicked(iIndex) {
	if(iRadioClicked == iIndex) {
		document.cmajor.not_offered[iIndex].checked = false;
		iRadioClicked = -1;
	}
	else
		iRadioClicked = iIndex;
	
}
</script>


<body bgcolor="#D2AE72">
<form name="cmajor" method="post" action="./curriculum_coursemajor.jsp">
<%@ page language="java" import="utility.*,enrollment.CurriculumCourseMajor,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-update course major","curriculum_coursemajor.jsp");
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
														"curriculum_coursemajor.jsp");
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

CurriculumCourseMajor CCM = new CurriculumCourseMajor();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(CCM.add(dbOP,request))
	{
		strErrMsg = "Course major added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CCM.getErrMsg()%></font></p>
		<%
		return;
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(CCM.edit(dbOP,request))
		{
			strErrMsg = "Course major edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=CCM.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(CCM.delete(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Course major deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=CCM.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
boolean bolProceed = true;
//convert the course information to its index.
String strCCode = request.getParameter("course_code");
String strCName = request.getParameter("course_name");
String strCCIndex = request.getParameter("cc_index");
String strCIndex = request.getParameter("c_index");

if(strCCode == null || strCCode.trim().length() ==0)
{
	bolProceed = false;
	strErrMsg = "Course code required. Please fill up course code.";
}
if(strCName == null || strCName.trim().length() ==0)
{
	bolProceed = false;
	strErrMsg = "Course name required. Please fill up course name.";
}
if(strCCIndex == null || strCCIndex.trim().length() ==0)
{
	bolProceed = false;
	strErrMsg = "Course classification required. Please fill up course code.";
}
if(strCIndex == null || strCIndex.trim().length() ==0)
{
	bolProceed = false;
	strErrMsg = "Course college offering name required. Please fill up Course college offering name.";
}

if(bolProceed)
{
	String strIndex = CCM.getCourseIndex(dbOP, strCCode, strCName,strCCIndex,strCIndex);
	if(strIndex == null)
	{
		strErrMsg = CCM.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Course information not found. please create course information before creating Major.";
		bolProceed = false;
	}
	else
		vRetResult = CCM.viewAll(dbOP, strIndex);
}

String strCC = dbOP.mapOneToOther("CCLASSIFICATION","CC_INDEX",strCCIndex,"CC_NAME",null );
String strCollege = dbOP.mapOneToOther("COLLEGE","C_INDEX",strCIndex,"C_NAME",null );
dbOP.cleanUP();

if(!bolProceed)
{%>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=strErrMsg%></font></p>
	<%
	return;
}


if(vRetResult == null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CCM.getErrMsg()%></font></p>
	<%
	return;
}

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSE MAJOR PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a></td>
      <td colspan="2" valign="bottom">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><u>Course code </u></td>
      <td colspan="2" valign="bottom"><u>Course name </u></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong><%=request.getParameter("course_code")%></strong></td>
      <td colspan="3"><strong><%=request.getParameter("course_name")%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><u>Course classification </u></td>
      <td width="42%" valign="bottom"><u>College offering the course</u> </td>
      <td width="3%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25"><strong><%=strCC%></strong></td>
      <td colspan="3"><strong><%=strCollege%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr></tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="6" height="25"><b><%=strErrMsg%></b></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td colspan="7" height="25"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Major
        <input type="text" name="major_name" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td colspan="3">Course Code:
        <input type="text" name="major_course_code" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <font size="1">
	    <input type="radio" name="not_offered" value="1" onClick="ButtonClicked('0')">
	    Not Offered (all) &nbsp;
	    <input type="radio" name="not_offered" value="2" onClick="ButtonClicked('1')"> 
	    Not Offered (new/transferee only)	  
	  </font>
	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="40">&nbsp;</td>
      <td width="29%" height="40">&nbsp; </td>
      <td width="38%" height="40">
        <%if(iAccessLevel > 1){%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0" name="imgAdd" ></a>
        <a href="javascript:cancelClicked();" onMouseOver="cancelon()" onMouseOut="canceloff()">
        <img src="../../../images/blank.gif" name="imgCancel" border="0"></a>
        <%}else{%>
        Not authorized to Add or Edit
        <%}%>      </td>
      <td width="20%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF MAJORS UNDER THIS
          COURSE</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
 <tr>
      <td height="25" class="thinborder" width="41%"><font size="1"><strong>MAJOR</strong></font></td>
      <td class="thinborder" width="22%"><font size="1"><strong>COURSE CODE</strong></font></td>
      <td class="thinborder" width="14%"><font size="1"><strong>IS OFFERED</strong></font></td>
      <td class="thinborder" width="5%"><font size="1"><strong>EDIT</strong></font></td>
      <td class="thinborder" width="15%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
<%
for(int i = 0; i<vRetResult.size(); ++i)
{
strTemp = (String)vRetResult.elementAt(i + 3);
if(strTemp.equals("0"))
	strTemp = "Not Offered.";
else if(strTemp.equals("2"))
	strTemp = "Not Offered (new/transferee).";
else	
	strTemp = "Y";
%>

    <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>", "<%=(String)vRetResult.elementAt(i+1)%>", "<%=(String)vRetResult.elementAt(i+2)%>")' onMouseOver="editon()" onMouseOut="editoff()" onClick="editClicked()">
        <img src="../../../images/edit.gif" name="imgEdit" border="0"></a>
        <%}%>      </td>
      <td class="thinborder">
        <%if(iAccessLevel ==2 ){%>
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete
        <%}%>      </td>
    </tr>
    <%
i = i+3;
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"></tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <%
  strTemp = request.getParameter("course_code");
  if(strTemp == null) strTemp = "";
  %>
  <input type="hidden" name="course_code" value="<%=strTemp%>">
  <%
  strTemp = request.getParameter("course_name");
  if(strTemp == null) strTemp = "";
  %>
  <input type="hidden" name="course_name" value="<%=strTemp%>">
  <%
  strTemp = request.getParameter("cc_index");
  if(strTemp == null) strTemp = "";
  %>
  <input type="hidden" name="cc_index" value="<%=strTemp%>">
  <%
  strTemp = request.getParameter("c_index");
  if(strTemp == null) strTemp = "";
  %>
  <input type="hidden" name="c_index" value="<%=strTemp%>">

<!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="0">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="0">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="caller_info_index" value="<%=WI.fillTextValue("caller_info_index")%>">
</form>
</body>
</html>
