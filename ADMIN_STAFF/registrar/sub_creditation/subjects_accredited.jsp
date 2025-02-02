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
	document.subaccredited.editRecord.value = 0;
	document.subaccredited.deleteRecord.value = 0;
	document.subaccredited.addRecord.value = 0;
	document.subaccredited.prepareToEdit.value = 0;

	document.subaccredited.submit();
}
function CancelRecord()
{
	var strSchIndex = document.subaccredited.sch_accr[document.subaccredited.sch_accr.selectedIndex].value;
	location="./subjects_accredited.jsp?sch_accr="+escape(strSchIndex);
}

function PrepareToEdit(strInfoIndex)
{
	document.subaccredited.editRecord.value = 0;
	document.subaccredited.deleteRecord.value = 0;
	document.subaccredited.addRecord.value = 0;
	document.subaccredited.prepareToEdit.value = 1;

	document.subaccredited.info_index.value = strInfoIndex;

	document.subaccredited.submit();
}
function AddRecord()
{
	if(document.subaccredited.sch_accr.selectedIndex ==0)
	{
		alert("please select an accredited school.");
		return;
	}
	if(document.subaccredited.prepareToEdit.value == 1)
	{
		EditRecord(document.subaccredited.info_index.value);
		return;
	}
	document.subaccredited.editRecord.value = 0;
	document.subaccredited.deleteRecord.value = 0;
	document.subaccredited.addRecord.value = 1;

	document.subaccredited.submit();
}
function EditRecord(strInfoIndex)
{
	document.subaccredited.editRecord.value = 1;
	document.subaccredited.deleteRecord.value = 0;
	document.subaccredited.addRecord.value = 0;

	document.subaccredited.info_index.value = strInfoIndex;
	document.subaccredited.submit();

}

function DeleteRecord(strInfoIndex)
{
	document.subaccredited.editRecord.value = 0;
	document.subaccredited.deleteRecord.value = 1;
	document.subaccredited.addRecord.value = 0;

	document.subaccredited.info_index.value = strInfoIndex;
	document.subaccredited.prepareToEdit.value == 0;

	document.subaccredited.submit();
}
function ReloadPage()
{
	document.subaccredited.addRecord.value = 0;
	document.subaccredited.editRecord.value = 0;
	document.subaccredited.deleteRecord.value = 0;

	document.subaccredited.prepareToEdit.value == 0;
	//document.subaccredited.reloadPage.value = 1;

	document.subaccredited.submit();
}

</script>


<body bgcolor="#D2AE72">
<form name="subaccredited" action="./subjects_accredited.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.Accredited,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-SUBJECT ACCREDITATION-Subject accridited","subjects_accredited.jsp");
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
//int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
//														"Registrar Management","SUBJECT ACCREDITATION",request.getRemoteAddr(),
//														"subjects_accredited.jsp");
iAccessLevel = 2;//allow to add subject.
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
	if(accredited.addSUB(dbOP,request))
	{
		strErrMsg = "Subject added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=accredited.getErrMsg()%></font></p>
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
		if(accredited.editSUB(dbOP,request))
		{
			strErrMsg = "Subject edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=accredited.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			if(accredited.delSUB(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Subject deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				<%=accredited.getErrMsg()%></font></p>
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
	vEditInfo = accredited.viewOneSUB(dbOP,request.getParameter("info_index"));
	if(vEditInfo.size() ==0 || vEditInfo == null)
		strErrMsg = accredited.getErrMsg();
}



int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = accredited.viewAllSUB(dbOP,request);

iSearchResult = accredited.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=accredited.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

%>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          SUBJECTS ACCREDITED PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><a href="subjects_accredited_main.jsp"><img src="../../../images/go_back.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="49%">School
        name
<%
//if(vEditInfo.size() > 0)
//	strTemp = (String)vEditInfo.elementAt(0);//school index.
//else
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
      <td width="2%">&nbsp;</td>
      <td colspan="4">School
        Address : <strong><%=(String)vSchInfo.elementAt(2)%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5" valign="middle"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="0%">&nbsp;</td>
      <td width="11%"><font size="1"><strong>SUB CODE </strong></font></td>
      <td width="30%" align="center"><font size="1"><strong>SUB DESCRIPTION </strong></font></td>
      <td width="7%"><font size="1"><strong>LEC. UNIT</strong></font></td>
      <td width="6%"><font size="1"><strong>LAB. UNIT</strong></font></td>
      <td width="22%"><font color="#0000FF" size="1" ><strong>EQUIV. SUBJECT CODE</strong></font></td>
      <td width="24%">&nbsp;</td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td  height="27">
        <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);//school index.
else
	strTemp = request.getParameter("sub_code");
if(strTemp == null) strTemp = "";
%>
        <input name="sub_code" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);//school index.
else
	strTemp = request.getParameter("sub_name");
if(strTemp == null) strTemp = "";
%>
      <td align="center"><input name="sub_name" type="text" size="24" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);//school index.
else
	strTemp = request.getParameter("lec_unit");
if(strTemp == null) strTemp = "";
%>
      <td><input name="lec_unit" type="text" size="2" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);//school index.
else
	strTemp = request.getParameter("lab_unit");
if(strTemp == null) strTemp = "";
%>
      <td><input name="lab_unit" type="text" size="2" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <%
if(vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);//school index.
else
	strTemp = request.getParameter("sub_index");
if(strTemp == null) strTemp = "";
%>
      <td><select name="sub_index">
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE"," from SUBJECT where IS_DEL=0 order by sub_code",strTemp , false)%>
        </select></td>
      <td>
        <%
strTemp = request.getParameter("prepareToEdit");
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a>
        <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25" colspan="7" valign="middle"><hr size="1"></td>
    </tr>
  </table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">LIST
          OF EXISTING SUBJECTS ACCREDITED</div></td>
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

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%">&nbsp;</td>
      <td width="14%"><font size="1"><strong>SUBJECT CODE </strong></font></td>
      <td width="42%"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>LEC. UNITS </strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>LAB. UNITS </strong></font></td>
      <td width="18%"><strong><font color="#0000FF" size="1" >EQUIV. SUBJECT CODE</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">EDIT</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr>
      <td>&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
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
 <table width="100%" bgcolor="#FFFFFF" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
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
