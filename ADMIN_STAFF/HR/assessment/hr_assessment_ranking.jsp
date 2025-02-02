<%@ page language="java" import="utility.*,java.util.Vector,hr.HRAssesRank, hr.HRSalaryGrade"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadSG(){
	document.form_.info_index.value = document.form_.sal_grade_index[document.form_.sal_grade_index.selectedIndex].value;
	document.form_.page_action.value ="";
	document.form_.submit();
}

function ReloadPage(){
	document.form_.submit();
}

function AddRecord(){
	document.form_.prepareToEdit.value = "";
	document.form_.page_action.value ="1";
	document.form_.submit();
}

function DeleteRecord(index){
	document.form_.prepareToEdit.value = "";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = index;
	document.form_.submit();
}
function EditRecord(index){
	document.form_.page_action.value = "2";
	document.form_.info_index.value = index;
	document.form_.submit();
}

function PrepareEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.submit();
}

function CancelRecord(){
	location = "./hr_assessment_ranking.jsp";
}
</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ASSESSMENT AND EVALUATION-Ranking system",
								"hr_assessment_ranking.jsp");

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
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_assessment_ranking.jsp");
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

Vector vRetResult = null;
Vector vRetEdit = null;
HRAssesRank hrAR  = new HRAssesRank();
HRSalaryGrade hrSG = new HRSalaryGrade();

strTemp = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (strTemp.compareTo("1") == 0){
	vRetResult = hrAR.operateOnRanking(dbOP,request,1);
	if (vRetResult != null){
		strPrepareToEdit = "0";
		strErrMsg = " Ranking added successfully.";
	}else{
		strErrMsg = hrAR.getErrMsg();
	}
}else if (strTemp.compareTo("0") == 0){
	vRetResult = hrAR.operateOnRanking(dbOP,request,0);
	if (vRetResult != null){
		strErrMsg = " Ranking deleted successfully.";
	}else{
		strErrMsg = hrAR.getErrMsg();
	}
}else if (strTemp.compareTo("2") == 0){
	vRetResult = hrAR.operateOnRanking(dbOP,request,2);
	if (vRetResult != null){
		strErrMsg = " Ranking edited successfully.";
		strPrepareToEdit = "";
	}else{
		strErrMsg = hrAR.getErrMsg();
	}
}

if (strPrepareToEdit.length() == 1){
	vRetEdit= hrAR.operateOnRanking(dbOP,request,3);
}
%>

<form action="./hr_assessment_ranking.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          RANKING SYSTEM PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
        <table width="95%" border="0" align="center">
          <tr>
            <td height="25"><div align="center"><strong>CRITERIA</strong></div></td>
<% if (vRetEdit != null && strPrepareToEdit.length() == 1){
		strTemp = (String)vRetEdit.elementAt(1);
	}else{
		strTemp = WI.fillTextValue("criteria_index");
	}
%>
            <td><select name="criteria_index" onChange="ReloadPage()">
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",strTemp,false)%>
				</select>
              <a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" alt="Refresh Page" width="71" height="23" border="0"></a> </td>
          </tr>
          <tr>
            <td width="21%" height="25"><div align="center"><strong>Effectivity
            Year : </strong></div></td>
<% if (vRetEdit != null && strPrepareToEdit.length() == 1){
		strTemp = (String)vRetEdit.elementAt(2);
		strTemp2 = (String)vRetEdit.elementAt(3);
	}else{
		strTemp = WI.fillTextValue("yr_from");
		strTemp2 = WI.fillTextValue("yr_to");
	}
%>
            <td width="79%"><strong>From</strong> 
			<input value="<%=strTemp%>" name="yr_from" type="text" id="yr_from" size="4" 
			maxlength="4"  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
			onblur="AllowOnlyInteger('form_','yr_from');style.backgroundColor='white'"
			onKeypress="AllowOnlyInteger('form_','yr_from');">
              <strong>To</strong> 
			  <input value="<%=WI.getStrValue(strTemp2)%>" name="yr_to" type="text" id="yr_to" size="4" 
			  maxlength="4"  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onblur="AllowOnlyInteger('form_','yr_to');style.backgroundColor='white'"
			   onKeyUp="AllowOnlyInteger('form_','yr_to');">
              <font size="1">(leave 'year to' empty if ranking is valid up to
            present)</font></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="15" colspan="2"><hr size="1"></td>
          </tr>
        </table>
        <table width="95%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr bgcolor="#FFFFFF">
            <td width="2%" height="25"><div align="center"></div></td>
            <td width="20%"><strong>Rank</strong></td>
<% if (vRetEdit != null && strPrepareToEdit.length() == 1)
		strTemp = (String)vRetEdit.elementAt(4);
	else
		strTemp = WI.fillTextValue("rank");
%>
            <td width="78%" height="25"><input value = "<%=strTemp%>" name="rank" type="text" id="rank" size="48"  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  ></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><div align="center"></div></td>
            <td height="25"><strong>Total Score Range</strong></td>
<% if (vRetEdit != null && strPrepareToEdit.length() == 1){
		strTemp = (String)vRetEdit.elementAt(5);
		strTemp2 = (String)vRetEdit.elementAt(6);
	}else{
		strTemp = WI.fillTextValue("score_from");
		strTemp2 = WI.fillTextValue("score_to");
	}
%>
            <td height="25"><input value="<%=strTemp%>" name="score_from" type="text" id="score_from" size="4"  class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','score_from');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','score_from')">
              to
              <input value="<%=strTemp2%>" name="score_to" type="text" id="score_to" size="4"  class="textbox"  
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','score_to');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','score_to')"></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><div align="center"></div></td>
            <td height="25"><strong>Salary Grade</strong></td>
            <%

	if (vRetEdit != null && strPrepareToEdit.length() == 1){
		strTemp = (String)vRetEdit.elementAt(7);
		strTemp2 = CommonUtil.formatFloat((String)vRetEdit.elementAt(10),false) + " -  " +
				  CommonUtil.formatFloat((String)vRetEdit.elementAt(11),false);
	}else{
		strTemp = WI.fillTextValue("sal_grade_index");
		
		vRetEdit = hrSG.operateOnSG(dbOP,request,3);

		if (vRetEdit !=null)
			strTemp2 =CommonUtil.formatFloat((String)vRetEdit.elementAt(2),true) + " - " +
				  CommonUtil.formatFloat((String)vRetEdit.elementAt(3),true);
		else
			strTemp2 = "";
	}
%>
            <td height="25"><select name="sal_grade_index" onChange="ReloadSG();">
              <option value="">Select A Salary Grade</option>
              <%=dbOP.loadCombo("SAL_GRADE_INDEX","GRADE_NAME"," FROM HR_PRELOAD_SAL_GRADE",strTemp,false)%>
            </select></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><div align="center"></div></td>
            <td height="25"><strong>Salary Range</strong></td>
            <td height="25"><strong><font color="#0000FF"><%=strTemp2%></font></strong> </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25">
              <%  if (iAccessLevel > 1){
		if (strPrepareToEdit.length() ==0){%>
              <a href="javascript:AddRecord();"><img src="../../../images/add.gif" width="42" height="32" border="0"></a>
			  <font size="1"> click to add new item </font>
              <%}else{ %>
             <a href="javascript:EditRecord('<%=WI.fillTextValue("info_index")%>');">
			 <img src="../../../images/edit.gif" border="0"></a>
              <font size="1">click to edit item</font>
			  <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click to cancel edit </font>
              <%}}%>            </td>
          </tr>
        </table>
<% 	vRetResult = hrAR.operateOnRanking(dbOP,request,4);
	if (vRetResult != null && vRetResult.size() > 0) {%>
        <table width="95%" border="1" align="center" cellpadding="0" cellspacing="0">
          <tr bgcolor="#CCCCCC">
            <td height="25" colspan="7"><div align="center"><strong>RANKING SYSTEM
                LIST</strong></div></td>
          </tr>
          <tr>
            <td width="10%" height="25"><div align="center"><font size="1"><strong>EFFECTIVITY
                YEAR </strong></font></div></td>
            <td><div align="center"><strong><font size="1">CRITERIA</font></strong></div></td>
            <td><div align="center"><font size="1"><strong>RANK</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>TOTAL SCORE RANGE</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>SALARY GRADE</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>SALARY RANGE</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>OPERATIONS</strong></font></div></td>
          </tr>
          <% for (int i =0; i < vRetResult.size() ; i+=12) { %>
          <tr>
            <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2) + " - " + WI.getStrValue((String)vRetResult.elementAt(i+3),"present")%></font></div></td>
            <td width="15%"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
            <td width="25%"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
            <td width="13%"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5) + " - " + (String)vRetResult.elementAt(i+6)%></font></div></td>
            <td width="10%"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></div></td>
            <td width="11%"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+10) + " - " + (String)vRetResult.elementAt(i+11)%></font></div></td>
            <td> <% if (iAccessLevel >1) {%> <a href="javascript:PrepareEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
              <%}else{%> &nbsp; <%} if (iAccessLevel == 2) {%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
			 <%}%>
		    </td>
          </tr>
          <%} //end for loop %>
        </table>
<%} // end vRetResult  != null%>

</tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
