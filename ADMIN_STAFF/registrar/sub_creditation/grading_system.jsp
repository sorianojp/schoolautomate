<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
	document.gradeaccredited.editRecord.value = 0;
	document.gradeaccredited.deleteRecord.value = 0;
	document.gradeaccredited.addRecord.value = 0;
	document.gradeaccredited.prepareToEdit.value = 0;

	document.gradeaccredited.submit();
}
function CancelRecord()
{
	var strSchIndex = document.gradeaccredited.sch_accr[document.gradeaccredited.sch_accr.selectedIndex].value;
	location="./grading_system.jsp?sch_accr="+escape(strSchIndex);
}

function PrepareToEdit(strInfoIndex)
{
	document.gradeaccredited.editRecord.value = 0;
	document.gradeaccredited.deleteRecord.value = 0;
	document.gradeaccredited.addRecord.value = 0;
	document.gradeaccredited.prepareToEdit.value = 1;

	document.gradeaccredited.info_index.value = strInfoIndex;

	document.gradeaccredited.submit();
}
function AddRecord()
{
	if(document.gradeaccredited.prepareToEdit.value == 1)
	{
		EditRecord(document.gradeaccredited.info_index.value);
		return;
	}
	document.gradeaccredited.editRecord.value = 0;
	document.gradeaccredited.deleteRecord.value = 0;
	document.gradeaccredited.addRecord.value = 1;

	document.gradeaccredited.submit();
}
function EditRecord(strInfoIndex)
{
	document.gradeaccredited.editRecord.value = 1;
	document.gradeaccredited.deleteRecord.value = 0;
	document.gradeaccredited.addRecord.value = 0;

	document.gradeaccredited.info_index.value = strInfoIndex;
	document.gradeaccredited.submit();

}

function DeleteRecord(strInfoIndex)
{
	document.gradeaccredited.editRecord.value = 0;
	document.gradeaccredited.deleteRecord.value = 1;
	document.gradeaccredited.addRecord.value = 0;

	document.gradeaccredited.info_index.value = strInfoIndex;
	document.gradeaccredited.prepareToEdit.value == 0;

	document.gradeaccredited.submit();
}
function ReloadPage()
{
	document.gradeaccredited.addRecord.value = 0;
	document.gradeaccredited.editRecord.value = 0;
	document.gradeaccredited.deleteRecord.value = 0;
	document.gradeaccredited.prepareToEdit.value == 0;

	//document.gradeaccredited.reloadPage.value = 1;

	document.gradeaccredited.submit();
}

</script>


<body bgcolor="#D2AE72">
<form name="gradeaccredited" action="./grading_system.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.Accredited,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-SUBJECT ACCREDITATION-Grade","grading_system.jsp");
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
														"Registrar Management","SUBJECT ACCREDITATION",request.getRemoteAddr(),
														"grading_system.jsp");
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

Accredited accredited = new Accredited();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(accredited.addGrade(dbOP,request))
	{
		strErrMsg = "Grade added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font  size="3"><%=accredited.getErrMsg()%></font></p>
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
		if(accredited.editGrade(dbOP,request))
		{
			strErrMsg = "Grade edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font  size="3"><%=accredited.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(accredited.delGrade(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Grade deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font  size="3"><%=accredited.getErrMsg()%></font></p>
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
	vEditInfo = accredited.viewOneGrade(dbOP,request.getParameter("info_index"));
	if(vEditInfo.size() ==0 || vEditInfo == null)
		strErrMsg = accredited.getErrMsg();
}



int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = accredited.viewAllGrade(dbOP,request);

iSearchResult = accredited.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font  size="3"><%=accredited.getErrMsg()%></font></p>
	<%
	return;
}

%>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOLS ACCREDITED GRADING SYSTEM PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="48%">School
        name
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(0);//school index.
else
	strTemp = request.getParameter("sch_accr");
%>
        <select name="sch_accr" onChange="ReloadPage();">
		<option value="selany">Select Any</option>
<%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0",strTemp , false)%>

        </select>
        </td>
<%//if strTemp == null || selany - do not show school name / code.
Vector vSchInfo = new Vector();
if(strTemp != null && strTemp.compareTo("selany") !=0)
{
	vSchInfo = accredited.viewOneSCH(dbOP, strTemp);
}
else
{
	vSchInfo.addElement("");vSchInfo.addElement("");vSchInfo.addElement("");
}
%>
      <td width="49%" colspan="3">
	  School
        code : <strong><%=(String)vSchInfo.elementAt(0)%></strong></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td colspan="4">School
        Address : <strong><%=(String)vSchInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5" valign="middle"><hr size="1"></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="50%">Final
        point equivalent :
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);//school index.
else
	strTemp = request.getParameter("final_pt");
if(strTemp == null) strTemp = "";
%>
 <input name="final_pt" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td height="25" width="47%">Status
        : &nbsp;&nbsp;&nbsp;<select name="status">
 <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);//school index.
else
	strTemp = request.getParameter("status");
if(strTemp == null) strTemp = "";
%>
<%=dbOP.loadCombo("STATUS_INDEX","STATUS"," from GRADE_STATUS where IS_DEL=0",strTemp , false)%>
<option value="other">Others(Pl specify)</option>

        </select>        <input name="other_status" type="text" size="15" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25"> Minimum
        percentage (%) required for the grade :
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);//school index.
else
	strTemp = request.getParameter("min_ptg");
if(strTemp == null) strTemp = "";
%>
 <input name="min_ptg" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>

      <td height="25">Remarks
        : <select name="remark">
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);//school index.
else
	strTemp = request.getParameter("remark");
if(strTemp == null) strTemp = "";
%>
<%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0",strTemp , false)%>
<option value="other">Others(Pl specify)</option>
        </select>
        <input name="other_remark" type="text" size="15" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25">Maximum
        percentage (%) required for the grade :
<%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);//school index.
else
	strTemp = request.getParameter("max_ptg");
if(strTemp == null) strTemp = "";
%>
 <input name="max_ptg" type="text" size="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>

<td ><%
if(iAccessLevel > 1){
	strTemp = request.getParameter("prepareToEdit");
	if(strTemp == null) strTemp = "0";
	if(strTemp.compareTo("0") == 0)
	{%>
		  <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a>
	<%}else{%>
		  <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a>
		  <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
	<%}
}//if iAccessLevel > 1%>
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
        Total Schools : <%=iSearchResult%> - Showing(<%=accredited.strDispRange%>)</b></td>
      <td width="34%">
	  <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/accredited.defSearchSize;
		if(iSearchResult % accredited.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
		<div align="right">Jump
          To page:
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
      <td width="15%"><div align="center"><strong><font size="1" >FINAL
          POINT </font></strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1" ><strong>MIN.%</strong></font></strong></div></td>
      <td width="9%" align="center"><strong><font size="1" >MAX.%</font></strong></td>
      <td width="27%" align="center"><strong><font size="1" >STATUS</font></strong></td>
      <td width="18%"><div align="center"><strong><font size="1" >REMARKS</font></strong></div></td>
      <td width="12%" align="center"><strong><font size="1" >EDIT</font></strong></td>
      <td width="11%" align="center"><strong><font size="1" >DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+1)%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+2)%></div></td>
      <td align="center"><div align="center"><%=(String)vRetResult.elementAt(i+3)%></div></td>
      <td align="center"><div align="center"><%=(String)vRetResult.elementAt(i+4)%></div></td>
      <td><div align="center"><%=(String)vRetResult.elementAt(i+5)%></div></td>
      <td align="center">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
      <td align="center">
<%if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
    </tr>
    <%
i = i+5;
}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
 <table width="100%" cellpadding="0"  cellspacing="0">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
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
