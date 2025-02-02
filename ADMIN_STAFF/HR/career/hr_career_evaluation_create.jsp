<%@ page language="java" import="utility.*,java.util.Vector,hr.HRCareerEvaluation" %>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function ChangeMainEval(){
	if(document.staff_profile.eval_main.selectedIndex >0)
		document.staff_profile.main_value.value = document.staff_profile.eval_main[document.staff_profile.eval_main.selectedIndex].text;
	else
		document.staff_profile.main_value.value = "";
	document.staff_profile.main_criteria_changed.value = "1";
	ReloadPage();
}

function ChangeCriteria(){
//	document.staff_profile.mainlabelname.value = "";
//	document.staff_profile.sublabelname.value = "";
	document.staff_profile.criteria_changed.value = "1";
	ReloadPage();
}

function ChangeSubEval(){
	if(document.staff_profile.sub_main.selectedIndex >0)
		document.staff_profile.eval_sub_value.value = document.staff_profile.sub_main[document.staff_profile.sub_main.selectedIndex].text;
	else
		document.staff_profile.eval_sub_value.value = "";
	ReloadPage();
}

function AddRecord(index){

	document.staff_profile.page_action.value="1";
	document.staff_profile.sublevel.value=index;
	if (index == 0){
		document.staff_profile.sub_index_value.value=document.staff_profile.main_value.value;
		document.staff_profile.main_value.value = "";
	}
	else
	{
		document.staff_profile.sub_index_value.value=document.staff_profile.eval_sub_value.value;
		document.staff_profile.eval_sub_value.value="";
	}
	document.staff_profile.submit();
}

function viewList(table,indexname,colname,labelname)
{
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function EditRecord(index)
{
	document.staff_profile.page_action.value="2";
	document.staff_profile.sublevel.value=index;
	document.staff_profile.submit();
}

function DeleteRecord(index)
{
	document.staff_profile.page_action.value="0";
	document.staff_profile.sublevel.value = index;
	if (index == 0)
		document.staff_profile.main_value.value = "";
	else
	{
		document.staff_profile.eval_sub_value.value="";
	}

	document.staff_profile.submit();
}

function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}


function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.setEdit.value = "0";
	document.staff_profile.info_index.value = index;
	ReloadPage();
}


</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;




//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_assessment.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_assessment_mgmt.jsp");
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

HRCareerEvaluation hrS = new HRCareerEvaluation();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));


if( iAction == 0 || iAction  == 1 || iAction == 2)
vRetResult = hrS.operateOnEvaluation(dbOP,request,iAction);


switch(iAction){
	case 0:{ // delete record
		if (vRetResult != null)
			strErrMsg = " Evaluation criteria record removed successfully.";
		else
			strErrMsg = hrS.getErrMsg();

		break;
	}
	case 1:{ // add Record
		if (vRetResult != null)
			strErrMsg = " Evaluation criteria record added successfully.";
		else
			strErrMsg = hrS.getErrMsg();
		break;
	}
	case 2:{ //  edit record
		if (vRetResult != null){
			strErrMsg = " Evaluation criteria record edited successfully.";
			strPrepareToEdit = "0";}
		else
			strErrMsg = hrS.getErrMsg();
		break;
	}
}
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          CAREER EVALUATION MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td><img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <font size="3"><%=WI.getStrValue(strErrMsg)%></font> <table width="85%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td height="25"><div align="left"><strong><font color="#0000FF" size="1">EVALUATION 
                CRITERIA</font></strong></div></td>
            <td> <select name="cIndex" id="cIndex" onChange='ChangeCriteria();'>
                <option value="">Select Evaluation Criteria</option>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> 
              </select> <strong><a href='javascript:viewList("HR_EVAL_CRITERIA","CRITERIA_INDEX","CRITERIA_NAME","EVALUATION CRITERIA");'><img src="../../../images/update.gif" border="0"></a> 
              </strong><font size="1">click to add evaluation criteria</font></td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><hr size="1" color="blue"></td>
          </tr>
        </table>
        <br> 
        <% strTemp = WI.fillTextValue("cIndex");
	if (strTemp.length()!= 0){
	strTemp2 = WI.fillTextValue("eval_main");
%>
        <table width="85%" border="0" align="center" cellpadding="3" cellspacing="0">
          <tr> 
            <td height="25" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE 
              MAIN ITEMS</font></strong></td>
          </tr>
          <tr> 
            <td width="21%">&nbsp;</td>
            <td width="79%"><select name="eval_main" id="select5" onChange="ChangeMainEval();">
                <option value="">Select Main Criteria</option>
                <%=dbOP.loadCombo("CE_MAIN_INDEX","CE_MAIN"," FROM HR_CE_MAIN where is_del=0 and is_valid=1 and CRITERIA_INDEX="+strTemp,strTemp2,false)%> 
              </select></td>
          </tr>
          <%
		if(WI.fillTextValue("criteria_changed").compareTo("1") != 0)
			strLabel = WI.fillTextValue("main_value");
%>
          <tr> 
            <td>&nbsp;</td>
            <td><textarea name="main_value" cols="40" rows="2" id="textarea" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"><%=strLabel%></textarea></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><font size="1" > 
              <%  if (iAccessLevel > 1){
		if (strLabel.length() ==0){%>
              <a href="javascript:AddRecord('0');"><img src="../../../images/add.gif" width="42" height="32" border="0"></a> 
              click to add new ITEM 
              <%}else{ %>
              <a href="javascript:EditRecord('0');"><img src="../../../images/edit.gif" border="0"></a> 
              click to edit ITEM 
              <%	if (iAccessLevel==2) {%>
              <a href="javascript:DeleteRecord('0')";><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>click 
              to delete selected ITEM 
              <%}}}%>
              </font></td>
          </tr>
        </table>
        <%
 if (strTemp2.length()!= 0 && strLabel.length()!= 0 && WI.fillTextValue("CE_MAIN").compareTo("1") != 0){
	strTemp3 = WI.fillTextValue("sub_main");
	strLabel = "";

		if(WI.fillTextValue("main_criteria_changed").compareTo("1") != 0)
			strLabel = WI.fillTextValue("eval_sub_value");
%>
        <table width="85%" border="0" align="center" cellpadding="3" cellspacing="0">
          <tr> 
            <td height="31" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE 
              SUB ITEM UNDER MAIN ITEM (<%=WI.fillTextValue("main_value")%>)</font></strong></td>
          </tr>
          <tr> 
            <td width="21%" height="25">&nbsp;</td>
            <td width="79%"><select name="sub_main" id="select4" onChange="ChangeSubEval();">
                <option value="">Select/Add Sub Criteria</option>
                <%=dbOP.loadCombo("CE_SUB_INDEX","CE_SUB"," FROM HR_CE_SUB where is_del=0 and is_valid=1 and CE_MAIN_INDEX="+strTemp2,strTemp3,false)%> 
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><textarea name="eval_sub_value" cols="40" rows="2" id="eval_sub_value" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"><%=strLabel%></textarea></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><font size="1" > 
              <%  if (iAccessLevel > 1){
		if (strLabel.length() ==0){%>
              <input name="image" type="image" onClick='AddRecord("1");' src="../../../images/add.gif" width="42" height="32">
              click to add new ITEM 
              <%}else{ %>
              <input name="image" type="image" onClick='EditRecord("1")' src="../../../images/edit.gif" border="0">
              click to edit ITEM 
              <%	if (iAccessLevel==2) {%>
              <input name="image" type="image" onClick='DeleteRecord("1")' src="../../../images/delete.gif" width="55" height="28" border="0">
              click to delete selected ITEM 
              <%}}}%>
              </font></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table>
        <%} // if main item selected%>
        <% vRetResult = hrS.operateOnEvaluation(dbOP,request,4);

	if (vRetResult !=null && vRetResult.size() > 0) {%>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td colspan="2"> <div align="center"><strong><font color="#000000" size="2">VIEW 
                ALL ITEM - SUB-ITEM LISTING FOR EVALUATION CRITERIA (<%=(String)vRetResult.elementAt(1)%>)</font></strong></div></td>
          </tr>
          <%
	strTemp = "";
	for (int i = 0; i < vRetResult.size(); i +=6) {
		if ((String)vRetResult.elementAt(i+3) != null){
%>
          <tr> 
            <td colspan="2" bgcolor="#CCCCCC"><strong><font color="#FF0000"><%=(String)vRetResult.elementAt(i+3)%> 
              </font></strong> <div align="center"></div></td>
          </tr>
          <%} //add new main criteria name%>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="87%"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></font></td>
          </tr>
          <%} //end for loop%>
        </table>
        <%}// end criteria listing
} // end criteria evalution selected%>
      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	  <input type="hidden" name="info_index" value="<%=strInfoIndex%>"> 
      <input type="hidden" name="page_action"> <input type="hidden" name="sublevel"> 
      <input type="hidden" name="reloadPage"> <input type="hidden" name="criteria_changed"> 
      <input type="hidden" name="main_criteria_changed"> <input type="hidden" name="sub_index_value"> 
</form>
</body>
</html>

<%
	dbOP.cleanUP();
%>