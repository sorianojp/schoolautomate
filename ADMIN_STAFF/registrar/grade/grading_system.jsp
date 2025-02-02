<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function gradeSystemExtn() {
	var newWnd = window.open("./grading_system_extn.jsp","Window",'width=900,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	newWnd.focus();
}

function goToNextSearchPage()
{
	document.gsystem.editRecord.value = 0;
	document.gsystem.deleteRecord.value = 0;
	document.gsystem.addRecord.value = 0;
	document.gsystem.prepareToEdit.value = 0;

	document.gsystem.submit();
}
function CancelRecord()
{
	location="./grading_system.jsp";
}

function PrepareToEdit(strInfoIndex)
{
	document.gsystem.editRecord.value = 0;
	document.gsystem.deleteRecord.value = 0;
	document.gsystem.addRecord.value = 0;
	document.gsystem.prepareToEdit.value = 1;

	document.gsystem.info_index.value = strInfoIndex;

	document.gsystem.submit();
}
function AddRecord()
{
	if(document.gsystem.prepareToEdit.value == 1)
	{
		EditRecord(document.gsystem.info_index.value);
		return;
	}
	document.gsystem.editRecord.value = 0;
	document.gsystem.deleteRecord.value = 0;
	document.gsystem.addRecord.value = 1;

	document.gsystem.submit();
}
function EditRecord(strInfoIndex)
{
	document.gsystem.editRecord.value = 1;
	document.gsystem.deleteRecord.value = 0;
	document.gsystem.addRecord.value = 0;

	document.gsystem.info_index.value = strInfoIndex;
	document.gsystem.submit();
}

function DeleteRecord(strInfoIndex)
{
	document.gsystem.editRecord.value = 0;
	document.gsystem.deleteRecord.value = 1;
	document.gsystem.addRecord.value = 0;

	document.gsystem.info_index.value = strInfoIndex;
	document.gsystem.prepareToEdit.value == 0;

	document.gsystem.submit();
}

function ShowHideStatus()
{
	if(document.gsystem.status.selectedIndex ==0)
	{
		document.gsystem.other_status.disabled = false;
		showLayer('status_');
	}
	else
	{
		hideLayer('status_');
		document.gsystem.other_status.disabled = true;
	}
}

function ShowHideRemark()
{
	if(document.gsystem.remark.selectedIndex ==0)
	{
		document.gsystem.other_remark.disabled = false;
		showLayer('remark_');
	}
	else
	{
		hideLayer('remark_');
		document.gsystem.other_remark.disabled = true;
	}
}

</script>


<body bgcolor="#D2AE72">
<form name="gsystem" action="./grading_system.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade System","grading_system.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grading System",request.getRemoteAddr(),
									null);

}

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

GradeSystem GS = new GradeSystem();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(GS.addGrade(dbOP,request))
	{
		strErrMsg = "Grade added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=GS.getErrMsg()%></font></p>
		<%
		return;
	}
}
else//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(GS.editGrade(dbOP,request))
		{
			strErrMsg = "Grade edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=GS.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(GS.delGrade(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Grade deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=GS.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}
// if prepareToEdit == 1; get school information to edit.
Vector vEditInfo = new Vector();
strTemp = request.getParameter("prepareToEdit");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{
	vEditInfo = GS.viewOneGrade(dbOP,request.getParameter("info_index"));
	
	if(vEditInfo.size() ==0 || vEditInfo == null)
		strErrMsg = GS.getErrMsg();
}



int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = GS.viewAllGrade(dbOP,request);

iSearchResult = GS.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=GS.getErrMsg()%></font></p>
	<%
	return;
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";	
%>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          GRADING SYSTEM PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="50%">Final point equivalent : 
        <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(0);//school index.
else
	strTemp = request.getParameter("final_pt");
if(strTemp == null) strTemp = "";
%> <input name="final_pt" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25" width="47%">Status : &nbsp;&nbsp;&nbsp;
        <select name="status" onChange="ShowHideStatus();">
          <option value="other">Others(Pl specify)</option>
          <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);//school index.
else
	strTemp = request.getParameter("status");
if(strTemp == null) strTemp = "";
%>
          <%=dbOP.loadCombo("STATUS_INDEX","STATUS"," from GRADE_STATUS where IS_DEL=0",strTemp , false)%> </select> <input name="other_status" type="text" size="15" id="status_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <%
if(strTemp.length() > 0){%> <script language="JavaScript">
if(!document.gsystem.other_status.disabled)
{
	hideLayer('status_');
	document.gsystem.other_status.disabled = true;
}
</script> <%}%> </td>
    </tr>
    <tr> 
      <td height="26" valign="middle">&nbsp;</td>
      <td height="26"> Minimum percentage (%) required for the grade : 
        <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);//school index.
else
	strTemp = request.getParameter("min_ptg");
if(strTemp == null) strTemp = "";
%> <input name="min_ptg" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="26">Remarks : 
        <select name="remark" onChange="ShowHideRemark();">
          <option value="other">Others(Pl specify)</option>
          <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);//school index.
else
	strTemp = request.getParameter("remark");
if(strTemp == null) strTemp = "";
%>
          <%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0",strTemp , false)%> </select> <input name="other_remark" type="text" size="15" id="remark_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <%
if(strTemp.length() > 0){%> <script language="JavaScript">
if(!document.gsystem.other_remark.disabled)
{
	hideLayer('remark_');
	document.gsystem.other_remark.disabled = true;
}
</script> <%}%> </td>
    </tr>
    <tr> 
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25">Maximum percentage (%) required for the grade : 
        <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);//school index.
else
	strTemp = request.getParameter("max_ptg");
if(strTemp == null) strTemp = "";
%> <input name="max_ptg" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td ><%
if(iAccessLevel > 1){

	strTemp = request.getParameter("prepareToEdit");
	if(strTemp == null) strTemp = "0";
	if(strTemp.compareTo("0") == 0)
	{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a> 
        <%}else{%> <a href="javascript:EditRecord(<%=(String)vEditInfo.elementAt(6)%>);"><img src="../../../images/edit.gif" border="0"></a> 
        <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <%}
}//if iAccessLevel > 1	%> </td>
    </tr>

<% if (vEditInfo.size() > 0) 
		 strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
	else
		strTemp = WI.fillTextValue("honor_point");
%>
	
    <tr>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25">Honor Point Equivalent : &nbsp;&nbsp;&nbsp;&nbsp;
        <input name="honor_point" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="5"></td>
      <td >
	  <%if(strSchCode.startsWith("WNU") || strSchCode.startsWith("WUP") || strSchCode.startsWith("SPC") || 
	  strSchCode.startsWith("DLSHSI") || strSchCode.startsWith("HTC")){%>
	  	<a href="javascript:gradeSystemExtn();"> Click to create multiple grading system </a>
	    <%}%>
	  </td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">CURRENT
          GRADING SYSTEM</div></td>
    </tr>
</table>
<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

<table width="100%" border="0" bgcolor="#FFFFFF">
<tr>
      <td width="66%" ><b>
        Total Schools : <%=iSearchResult%> - Showing(<%=GS.strDispRange%>)</b></td>
      <td width="34%">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/GS.defSearchSize;
		if(iSearchResult % GS.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Jump
          To page: </font>
          <select name="jumpto" onChange="goToNextSearchPage();">

		<%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%
					}
			}
			%>
			 </select>

		<%}%>

        </div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%"><div align="center"><font size="1"><strong>FINAL POINT </strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>MIN. %</strong></font></div></td>
      <td width="10%" align="center"><div align="center"><font size="1"><strong>MAX. 
          % </strong></font></div></td>
      <td width="13%" align="center"><font size="1"><strong>HONOR POINT</strong></font></td>
      <td width="18%" align="center"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
      <td width="10%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="14%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%

	
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr> 
      <td><div align="center"><%=(String)vRetResult.elementAt(i+1)%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+2)%></div></td>
      <td align="center"><div align="center"><%=(String)vRetResult.elementAt(i+3)%></div></td>
      <td align="center"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i+6),"Not Set")%></div></td>
      <td align="center"><div align="center"><%=(String)vRetResult.elementAt(i+4)%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+5)%></div></td>
      <td align="center"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized
        <%}%> </td>
      <td align="center"> <%if(iAccessLevel ==2){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized
        <%}%> </td>
    </tr>
    <%
i = i+6;
}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
  <table width="100%"  cellpadding="0" cellspacing="0">
    <tr>
      <td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td>&nbsp;</td>
    </tr>
  </table>

<!-- all hidden fields go here -->
<%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<%
strTemp = request.getParameter("prepareToEdit");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="prepareToEdit" value="<%=strTemp%>">
<input type="hidden" name="deleteRecord" value="0">

  </form>
</body>
</html>


<%
dbOP.cleanUP();
%>
