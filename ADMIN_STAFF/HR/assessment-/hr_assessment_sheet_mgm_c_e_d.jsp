<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function ChangeMainEval(){
	document.staff_profile.labelname.value = document.staff_profile.eval_main[document.staff_profile.eval_main.selectedIndex].text;
	ReloadPage();
}

function ChangeCriteria(){
	ReloadPage();
}

function ChangeSubEval(){
	ReloadPage();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
}


function DeleteRecord(index)
{
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	document.staff_profile.submit();
}

function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}


</script>
<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationPoints" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;



//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_education.jsp");
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
Vector vRetResult = new Vector();
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String strInfoIndex = request.getParameter("info_index");

strPrepareToEdit = "0";
String strLabel = "";

HREvaluationPoints hrS = new HREvaluationPoints();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));


if( iAction == 0 || iAction  == 1){
vRetResult = hrS.operateOnEvaluationPoints(dbOP,request,iAction);
	switch(iAction){
		case 0:{ // delete record
			if (vRetResult != null)
				strErrMsg = " Evaluation criteria point record removed successfully.";
			else
				strErrMsg = hrS.getErrMsg();

			break;
		}
		case 1:{ // add Record
			if (vRetResult != null)
				strErrMsg = " Evaluation criteria point record added successfully.";
			else
				strErrMsg = hrS.getErrMsg();
			break;
		}
	}
}
%>
<body bgcolor="#663300">
<form action="./hr_assessment_sheet_mgm_c_e_d.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          EVALUATION SHEET MANAGEMENT - CREATE/EDIT/DELETE/VIEW PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><a href="hr_assessment_sheet_mgmt_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  <font size="3"><%=WI.getStrValue(strErrMsg,"")%></font>
        </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
	<table width="85%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr>
            <td width="18%"><strong>Criteria for</strong></td>
            <td width="27%"><select name="cIndex" id="cIndex" onChange='ChangeCriteria();'>
                <option value="">Select Evaluation Criteria</option>
<%
	strTemp = WI.fillTextValue("cIndex");
%>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",strTemp,false)%> </select> </td>
            <td><strong>Evaluation Sheet for Year
              <input name="sy_from" type="text" class="textbox" id="sy_from"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="4" maxlength="4"
			  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
			  value="<%=WI.fillTextValue("sy_from")%>">
              to
              <input name="sy_to" type="text" class="textbox" id="sy_to"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="4" maxlength="4"
			  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
			  value="<%=WI.fillTextValue("sy_to")%>">
              <img src="../../../images/refresh.gif" border="0" onClick="ReloadPage();"> </strong></td>
          </tr>
          <tr>
            <td colspan="3"><hr size="1"></td>
          </tr>
        </table>
<% if (strTemp.length()!=0 &&
       WI.fillTextValue("sy_from").length()==4 &&
	   WI.fillTextValue("sy_to").length()==4){%>

        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td width="18%" height="25"><strong>Available Items</strong></td>
            <td width="82%"> <%
	strTemp2 = WI.fillTextValue("eval_main");
	if (strTemp.length() != 0){
%> <select name="eval_main" id="select5" onChange="ChangeMainEval();">
                <option value="">Select Main Criteria</option>
                <%=dbOP.loadCombo("CRITERIA_MAIN_INDEX","CRITERIA_MAIN"," FROM HR_EVAL_CRITERIA_MAIN where is_del=0 and is_valid=1 and CRITERIA_INDEX="+strTemp,strTemp2,false)%> </select> <%}%> &nbsp; </td>
          </tr>
          <tr> 
            <td height="25"><strong>Item Order No.</strong></td>
            <td> <% int iCount = 0;
	if (strTemp2.length() != 0) {
	try {
		iCount = Integer.parseInt(dbOP.mapOneToOther("HR_EVAL_CRITERIA_MAIN","is_del","0","count(*)"," and is_valid=1 and criteria_index="+strTemp));
	}
	catch (NumberFormatException NFE){
		iCount = 0;
	}
%> <select name="iOrderMain">
                <% for ( int i=1 ; i <=iCount ; i++){%>
                <option value="<%=i%>"><%=i%></option>
                <%} //end for loop%>
              </select> <%} //end strTemp2 lenght !=0%> &nbsp;</td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><hr size="1" color="blue"></td>
          </tr>
          <%

	strTemp3 = WI.fillTextValue("sub_main");
	strLabel = "";

	if (strTemp2.length() != 0) strLabel ="&lt;"+ WI.fillTextValue("labelname")+"&gt;";
%>
          <tr> 
            <td height="25" colspan="2"><strong>Available Sub-ITEM under the ITEM 
              <%=WI.getStrValue(strLabel,"")%></strong></td>
          </tr>
          <tr> 
            <td height="30" colspan="2"> <%if (strTemp2.length() != 0){%> <select name="sub_main" id="sub_main">
                <%=dbOP.loadCombo("CRITERIA_SUB_INDEX","CRITERIA_SUB"," FROM HR_EVAL_CRITERIA_SUB where is_del=0 and is_valid=1 and CRITERIA_MAIN_INDEX="+strTemp2,strTemp3,false)%> </select> <%}%> &nbsp;</td>
          </tr>
          <tr> 
            <td height="25"><strong>Sub-ITEM Points</strong></td>
            <td><input name="points" type="text" class="textbox" id="points"  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="3"></td>
          </tr>
          <tr> 
            <td height="25"><strong>Sub-ITEM Order No.</strong></td>
            <td> <% if (strTemp2.length()!=0){
	try {
		iCount = Integer.parseInt(dbOP.mapOneToOther("HR_EVAL_CRITERIA_SUB","is_del","0","count(*)"," and is_valid=1 and CRITERIA_MAIN_INDEX="+strTemp2));
	}
	catch (NumberFormatException NFE){
		iCount = 0;
	}
%> <select name="iOrderSub">
                <% for ( int i=1 ; i <=iCount ; i++){%>
                <option value="<%=i%>"><%=i%></option>
                <%} //end for loop%>
              </select> <%} //end strTemp2 lenght !=0%> </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td> <% if (iCount > 0){%> <input name="image22" type="image" onClick="AddRecord();" src="../../../images/add.gif"> 
              <font size="1">click to add new SUB ITEM</font> <%}%> </td>
          </tr>
        </table>
<% vRetResult = hrS.operateOnEvaluationPoints(dbOP,request,4);
if ( vRetResult != null && vRetResult.size() > 0) {%>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr bgcolor="#CCCCCC">
            <td colspan="4"> <div align="center"><strong>VIEW ALL ITEM - SUB-ITEM
                LISTING FOR &lt;<%=(String)vRetResult.elementAt(10)%>&gt;</strong></div></td>
          </tr>
<% strTemp = "";
   for (int i = 0; i < vRetResult.size() ; i +=12){
       if (strTemp.compareTo((String)vRetResult.elementAt(i+9)) != 0) {
	   	   strTemp = (String)vRetResult.elementAt(i+9);
   %>
          <tr>
            <td colspan="4" bgcolor="#ffffff">&nbsp;</td>
          </tr>
          <tr>
            <td height="25" colspan="4" bgcolor="#CCCCCC"><strong><font color="#FF0000"><%=strTemp%></font></strong>
              <div align="center"></div></td>
          </tr>
<%}%>
          <tr>
            <td width="5%">&nbsp;</td>
            <td width="79%"><%=(String)vRetResult.elementAt(i+8)%></td>
            <td width="8%" align="center"><%=(String)vRetResult.elementAt(i+4)%></td>
            <td width="8%" align="center"><input type="image" src="../../../images/delete.gif" border="0"
			onClick='DeleteRecord("<%=(String)vRetResult.elementAt(i+11)%>")'>
            </td>
          </tr>
<%} //end for loop%>
        </table>
        <hr size="1">

<%} // end Listing Table
} //end complete data (criteria index, and years)%>
	</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="sublevel">
<input type="hidden" name="reloadPage">
<input type="hidden" name="labelname" value = "<%=WI.fillTextValue("labelname")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

