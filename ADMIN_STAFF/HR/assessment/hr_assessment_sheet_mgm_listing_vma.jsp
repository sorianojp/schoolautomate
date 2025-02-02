<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet, hr.HREvaluationSheetExtn" %>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.staff_profile.page_action.value="5";
	document.staff_profile.submit();
}
function ReloadPage() {
	document.staff_profile.is_active_value.value="";
	document.staff_profile.EVAL_SHEET_MAIN_INDEX.value = "";
	document.staff_profile.page_action.value="";
	this.SubmitOnce('staff_profile');
}

function ShowHideTDLayer(strInfoIndex,strActiveValue) {
	document.staff_profile.EVAL_SHEET_MAIN_INDEX.value = strInfoIndex;	
	document.staff_profile.page_action.value="";
	document.staff_profile.is_active_value.value=strActiveValue;
	document.staff_profile.submit();
}


</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ASSESSMENT AND EVALUATION-Evaluation Sheet","hr_assessment_sheet_mgm_listing_vma.jsp");
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
														"hr_assessment_sheet_mgm_listing_vma.jsp");
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
Vector vEvalPeriod = null;
HREvaluationSheet hrEvalSheet = new HREvaluationSheet();

HREvaluationSheetExtn ESExtn = new HREvaluationSheetExtn();


String strCriteriaIndex = WI.fillTextValue("cIndex");


if(WI.fillTextValue("page_action").length() > 0) {
//	if(hrEvalSheet.operateOnEvaluationPoints(dbOP, request, 5) == null)
//		strErrMsg = hrEvalSheet.getErrMsg();
//	else	
//		strErrMsg = "Active status changed successfully.";
	String strActiveIndex = WI.fillTextValue("is_active");
    if (strActiveIndex.length() == 0) 
    	strErrMsg = "Please select a year and click save to change its active status.";        
    else{
		String strEvalSheetMainIndex = WI.fillTextValue("EVAL_SHEET_MAIN_INDEX");
		if(strEvalSheetMainIndex.length() == 0)
			strErrMsg = "Please select evaluation period.";
		else{
			strTemp = "update HR_EVAL_SHEET_MAIN set is_active = 0  where is_valid = 1 and criteria_index = "+strCriteriaIndex;
			int iRowUpdated = dbOP.executeUpdateWithTrans(strTemp, null, null, false);
			if (iRowUpdated != -1) {
				strTemp = "update HR_EVAL_SHEET_MAIN set is_active = 1  where eval_sheet_main_index = " + strEvalSheetMainIndex;
				iRowUpdated = dbOP.executeUpdateWithTrans(strTemp , null, null, false);
				if (iRowUpdated < 1) {
					strErrMsg = "Error in connection. Please try again.";
					System.out.println(strTemp);				
				}else{
					strTemp = "update HR_EVAL_EVALPERIOD set is_active = 0 where IS_VALID =1 and EVAL_SHEET_MAIN_INDEX = "+strEvalSheetMainIndex;
					iRowUpdated = dbOP.executeUpdateWithTrans(strTemp, null, null, false);
					if (iRowUpdated != -1) {
						strTemp = "update HR_EVAL_EVALPERIOD set is_active = 1  where EVAL_PERIOD_INDEX = " + strActiveIndex;
						iRowUpdated = dbOP.executeUpdateWithTrans(strTemp , null, null, false);
						if (iRowUpdated < 1) {
							strErrMsg = "Error in connection. Please try again.";
							System.out.println(strTemp);				
						}else
							strErrMsg = "Active status changed successfully.";
					}				
				}
			}
		}				
	}
}

if (WI.fillTextValue("cIndex").length() > 0){
	vRetResult = hrEvalSheet.operateOnEvaluationPoints(dbOP,request,3);	
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = hrEvalSheet.getErrMsg();	
}
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_assessment_sheet_mgm_listing_vma.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          EVALUATION SHEET MANAGEMENT -LISTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><strong><a href="./hr_assessment_sheet_mgmt_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	   <%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td>
<%
	strTemp = WI.fillTextValue("cIndex");
	if (strTemp.length() > 0){
%>	  
	   <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
<%}%>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td width="51%" height="25"><div align="center"><strong>Criteria for</strong></div></td>
             <td  width="49%"> <select name="cIndex" id="cIndex" onChange='ReloadPage();'>
                <option value="" selected>Select Evaluation Criteria</option>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> </select></td>
            
          </tr>
          <% if ((strTemp.length() > 0) && vRetResult != null  && vRetResult.size() > 0){ %>
          <tr bgcolor="#CCCCCC"> 
            <td height="25" colspan="2"><div align="center"><strong>LIST OF EVALUATION 
                SHEETS </strong></div></td>
          </tr>
          <tr> 
            <td height="25"><strong>SHEET YEAR</strong></td>
            <td align="center"><strong>IS ACTIVE</strong></td>
          </tr>
          <%for (int i = 0; i < vRetResult.size() ; i+=5) {%>
          <tr> 
            <td height="25"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%> - <%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></td>
            <td align="center">             </td>
          </tr>

		  <%
		  vEvalPeriod = ESExtn.getEvaluationPeriod(dbOP,(String)vRetResult.elementAt(i));
		  if(vEvalPeriod == null)
		  	continue;
		  
		  for(int x =0 ; x < vEvalPeriod.size(); x+=10){
		  %>
		  <tr>
		  	<td style="padding-left:60px;">&nbsp;<%=vEvalPeriod.elementAt(x+1)%>-<%=vEvalPeriod.elementAt(x+2)%></td>
			<td align="center">
			
			<%
			
			strTemp = "";
			if(WI.fillTextValue("is_active_value").equals((String)vEvalPeriod.elementAt(x)))
				strTemp = " checked";
			else if(WI.fillTextValue("is_active_value").length() == 0 ){
				strTemp = (String)vEvalPeriod.elementAt(x + 3);
				if(strTemp != null && strTemp.compareTo("1") == 0) 
					strTemp = " checked";
			}
			
			
			%>
                <input type="radio" name="is_active" value="<%=(String)vEvalPeriod.elementAt(x)%>" 
					onClick="ShowHideTDLayer('<%=(String)vRetResult.elementAt(i)%>','<%=(String)vEvalPeriod.elementAt(x)%>');"<%=strTemp%>>
				
			</td>
		  </tr>
		  <%}//end for(int x =0 ; x < vEvalPeriod.size(); x+=10)
		  
		  } // end for loop%>
          <tr> 
            <td height="10"></td>
            <td>&nbsp;</td>
          </tr>
<%
if(iAccessLevel > 1) {%>
          <tr id="row_1"> 
            <td height="25" colspan="2" align="center"><a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a>Click 
                to change active state.<font size="1"><br>
                <strong>NOTE: By default highest year is active unless active 
                state is set to other year level.</strong></font>              </td>
            </tr>
	  
   <%}
} // end listing
%>
        </table>

      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="EVAL_SHEET_MAIN_INDEX" value="<%=WI.fillTextValue("EVAL_SHEET_MAIN_INDEX")%>">

<input type="hidden" name="is_active_value" value="<%=WI.fillTextValue("is_active_value")%>">
</form>
</body>
</html>

<%
	dbOP.cleanUP();
%>