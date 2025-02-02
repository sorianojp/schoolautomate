<%@ page language="java" import="utility.*,payroll.PReDTRME,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Period Auto</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
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
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.schedule.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function DeletePeriod(){
  var vProceed = confirm('Are you sure you want to delete the unused periods for the year range?');
  if(vProceed){	
	document.form_.delete_period.value = "1";
	this.SubmitOnce('form_');
  }
}

function viewList(table, indexname, colname, labelname, tablelist, strIndexes,  strExtraTableCond, strExtraCond, strFormField){
//	alert("table " + table);
//	alert("indexname " + indexname);
//	alert("colname " + colname);
//	alert("labelname " + labelname);
//	alert("tablelist " + tablelist);
//	alert("strIndexes " + strIndexes);
//	alert("strExtraTableCond " + strExtraTableCond);
//	alert("strExtraCond " + strExtraCond);
//	alert("strFormField " + strFormField);
	
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CancelRecord(){
	location = "./salary_period_range.jsp";
}					
function ShowHideLabel(strLabel){
	if(strLabel == '1'){		
		document.getElementById("lbl_help").style.visibility = "visible";
	}else{
		document.getElementById("lbl_help").style.visibility = "hidden";
	}
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Auto create Salary Period","salary_period_range.jsp");
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
														"Payroll","DTR",request.getRemoteAddr(),
														"salary_period_range.jsp");
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

	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	int iTemp = 0;
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(!prEdtrME.generateSalaryPeriodNew(dbOP, request))
			strErrMsg = prEdtrME.getErrMsg();
		else
			strErrMsg = "Salary periods generated successfully";	
	}
	
	if(WI.fillTextValue("delete_period").length() > 0){		
		if(!prEdtrME.removeUnusedPeriod(dbOP, request))
			strErrMsg = prEdtrME.getErrMsg();
		else
			strErrMsg = "Salary periods removed successfully";	
		
	}
	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./salary_period_range.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SALARY PERIOD SETTING ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="23" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="4%">&nbsp;</td>
          <td width="21%">Salary Period Name :            </td>
            <%	
				strTemp= WI.fillTextValue("period_index");
			%>
          <td width="75%"><select name="period_index">
            <%=dbOP.loadCombo("PERIOD_INDEX","PERIOD_NAME", " from pr_preload_period order by period_name",strTemp,false)%>
          </select>
		  <!--table, indexname, colname, labelname, tablelist, strIndexes,  strExtraTableCond, strExtraCond, strFormField-->
          <%if(iAccessLevel > 1){%>
					  <a href='javascript:viewList("pr_preload_period","period_index","period_name", "PERIOD NAME", 
					"PR_EDTR_SAL_PERIOD","period_index"," and PR_EDTR_SAL_PERIOD.IS_VALID = 1","",
					"period_index");'><img src="../../../images/update.gif" border="0" ></a><font size="1">click				
      to add to the salary period name </font>
					<%}%>					</td>
        </tr>
      </table></td>
    </tr>
    
    <tr> 
      <td height="94" colspan="3"><div align="center"> 
          <%if(WI.fillTextValue("whole_month").length() > 0){%>
          <table width="100%" height="64" border="1" cellpadding="5" cellspacing="0">
            <tr bgcolor="#FFFFFF"> 
              <td width="50%" align="center">SALARY PERIOD START DAY</td>
              <td width="50%" height="26" align="center">SALARY DTR CUT-OFF 
              DAY</td>
            </tr>
            <tr bgcolor="#FFFFFF"> 
              <td align="center"> 
                <select name="sal_period_fr">
                  <%
				strTemp = WI.getStrValue(WI.fillTextValue("sal_period_fr"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(int i=1; i<=30; ++i){ 
				  if(iTemp == i){%>
                  <option selected value="<%=i%>"><%=i%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%></option>
                  <%}
				}%>
                  <%if(strTemp.equals("31")){%>
                  <option selected value="31">EOM</option>
                  <%}else{%>
                  <option value="31">EOM</option>
                  <%}%>
                </select>              </td>
              <td height="36" align="center">  
                <select name="dtr_cut_off_to">
                  <%
				strTemp = WI.getStrValue(WI.fillTextValue("dtr_cut_off_to"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(int i=1; i<=30; ++i){ 
				  if(iTemp == i){%>
                  <option selected value="<%=i%>"><%=i%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%></option>
                  <%}
				}%>
                  <%if(strTemp.equals("31")){%>
                  <option selected value="31">EOM</option>
                  <%}else{%>
                  <option value="31">EOM</option>
                  <%}%>
                </select>              </td>
            </tr>
          </table>
          <%}// end for whole Month
		    else{
		  %>
          <table width="100%" height="94" border="1" cellpadding="5" cellspacing="0">
            <tr bgcolor="#FFFFFF"> 
              <td colspan="2" align="center">SALARY PERIOD</td>
              <td height="29" colspan="2" align="center">SALARY DTR CUT-OFF 
                RANGE</td>
              <td height="29">&nbsp;</td>
            </tr>
            <tr bgcolor="#FFFFFF"> 
              <td width="17%" align="center">FROM</td>
              <td width="17%" align="center">TO</td>
              <td width="17%" align="center">FROM</td>
              <td width="20%" height="26" align="center">TO</td>
              <td width="29%" height="26" align="center">PAY PERIOD</td>
            </tr>
            <tr bgcolor="#FFFFFF"> 
              <td align="center"> 
                  <select name="sal_period_fr">
                    <%
				strTemp = WI.getStrValue(WI.fillTextValue("sal_period_fr"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(int i=1; i<=30; ++i){ 
				  if(iTemp == i){%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}
				}%>
                    <%if(strTemp.equals("31")){%>
                    <option selected value="31">EOM</option>
                    <%}else{%>
                    <option value="31">EOM</option>
                    <%}%>
                </select>                </td>
              <td align="center"> 
                  <select name="sal_period_to">
                    <%
								strTemp = WI.getStrValue(WI.fillTextValue("sal_period_to"),"15");
								iTemp = Integer.parseInt(strTemp);
								for(int i=1; i<=30; ++i){ 
									if(iTemp == i){%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}
									}%>
                    <%if(strTemp.equals("31")){%>
                    <option selected value="31">EOM</option>
                    <%}else{%>
                    <option value="31">EOM</option>
                    <%}%>
                </select>                </td><td align="center">  
                      <select name="dtr_cut_off_from">
                        <%
				strTemp = WI.getStrValue(WI.fillTextValue("dtr_cut_off_from"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(int i=1; i<=30; ++i){ 
				  if(iTemp == i){%>
                        <option selected value="<%=i%>"><%=i%></option>
                        <%}else{%>
                        <option value="<%=i%>"><%=i%></option>
                        <%}
				}%>
                        <%if(strTemp.equals("31")){%>
                        <option selected value="31">EOM</option>
                        <%}else{%>
                        <option value="31">EOM</option>
                        <%}%>
                  </select>
                  </td>
              <td height="36" align="center">  
                  <select name="dtr_cut_off_to">
                    <%
				strTemp = WI.getStrValue(WI.fillTextValue("dtr_cut_off_to"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(int i=1; i<=30; ++i){ 
				  if(iTemp == i){%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}
				}%>
                    <%if(strTemp.equals("31")){%>
                    <option selected value="31">EOM</option>
                    <%}else{%>
                    <option value="31">EOM</option>
                    <%}%>
                </select>              </td>
              <td height="36" align="center"> 
                  <select name="sal_period">
                    <option value="1">First</option>
                    <%
strTemp = WI.getStrValue(WI.fillTextValue("sal_period"),"0");
if(strTemp.compareTo("2") ==0){%>
                    <option value="2" selected>Second</option>
                    <%}else{%>
                    <option value="2">Second</option>
                    <%}if(strTemp.compareTo("3") ==0){%>
                    <option value="3" selected>Third</option>
                    <%}else{%>
                    <option value="3">Third</option>
                    <%}if(strTemp.compareTo("4") ==0){%>
                    <option value="4" selected>Fourth</option>
                    <%}else{%>
                    <option value="4">Fourth</option>
                    <%}%>
                </select>                </td></tr>
          </table>
          <%}%>
        </div></td>
    </tr>
    <tr> 
      <%
		strTemp = WI.fillTextValue("start_year");
		if(strTemp.length() == 0)
		    strTemp = WI.getTodaysDate(12);
	%>
      <td width="25%" height="24"> <div align="right"><font size="1"><strong> 
          Starting Year: 
          <input name="start_year" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"")%>"
			  onKeyUp="AllowOnlyInteger('form_','start_year');" style="text-align : right"
			  onBlur="AllowOnlyInteger('form_','start_year');style.backgroundColor='white'">
          </strong></font></div></td>
      <%
		strTemp = WI.fillTextValue("end_year");
		if(strTemp.length() == 0)
		    strTemp = WI.getTodaysDate(12);
	%>
      <td width="23%"><font size="1"><strong>&nbsp;&nbsp;&nbsp;&nbsp;End Year: 
        <input name="end_year" type="text" size="10" maxlength="10" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"")%>"
			  onKeyUp="AllowOnlyInteger('form_','end_year');" style="text-align : right"
			  onBlur="AllowOnlyInteger('form_','end_year');style.backgroundColor='white'">
        </strong></font></td>
      <%
	  	if(WI.fillTextValue("whole_month").length() > 0)	{
			strTemp = " checked";
		}else{
			strTemp = "";
		}
	  %>
      <td width="52%" height="24"><font size="1"><strong> 
        <input type="checkbox" name="whole_month" value="1" <%=strTemp%> onClick="ReloadPage();">
        Whole Month
      
	  <%
			if(WI.fillTextValue("use_previous").length() > 0){
				strTemp = " checked";
			}else{
				strTemp = "";
			}
	  %>		
        <input type="checkbox" name="use_previous" value="1" <%=strTemp%>>
        Use Previous Month data for Cut off			
</strong></font></td>
    </tr>
    <tr> 
      <td height="42" colspan="3" align="center">
				<%if(iAccessLevel > 1){%>
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/auto_sched.gif" name="hide_save" width="55" height="40" border="0"></a> 
				-->
        <input type="button" name="schedule" value=" Schedule " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        <font size="1">Click to save</font>
        <!--
					<a href="./salary_period_range.jsp"><img src="../../../images/cancel.gif" border="0"></a> 
					-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
        <font size="1">Click to clear fields</font>
				<%}%>			</td>
    </tr>
    <tr>
      <td height="28" colspan="3" align="center">
			<%if(iAccessLevel == 2){%>
			<!--
			<a href="javascript:DeletePeriod()"><img src="../../../images/delete.gif" border="0"></a>
			-->
			<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:DeletePeriod();">
			<font size="1">Delete unused salary Periods</font>
			<%}%>			</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="delete_period">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>