<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRTaxReport" 
				 buffer="16kb"%>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<title>Bureau of Internal Revenue - 1601-C</title>
<style>
	body{
		margin:0px;
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		color:#333333;
		font-weight:normal;
	}

	.container{
		border:4px #333333 solid;
	}
	
	.marginBottom{
		margin-bottom:2px;
	}
	.borderBottom{
		border-bottom:4px #333333 solid;
	}
	.borderBottomII{
		border-bottom:1px #333333 solid;
	}
	.borderRight{
		border-right:1px #333333 solid;
		background-color:#CCCCCC;
	}
	.borderRightBottom{
		border-bottom:1px #333333 solid;
		border-right:1px #333333 solid;
	}
	.borderLeft{
		border-left: 4px #333333 solid;
	}
	.textTitleHeader{
		font-family:Arial, Helvetica, sans-serif;
		font-size:21px;
		font-weight:bold;
		color:#333333;
	}
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
	}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.print_pg.value = "";
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ReloadPage(){
	document.form_.print_pg.value = "";
	document.form_.submit();
}

function SaveRecord(){
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "1";
	document.form_.submit();
}

function EditRecord(strInfoIndex){
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "2";
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}

function DeleteRecord(strInfoIndex){
	document.form_.print_pg.value = "";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}

function CancelRecord(){
	location = "./form_1601c.jsp";
}

function PrintPage(){
	document.form_.print_pg.value = "1";
 	this.SubmitOnce('form_');
}
   
function focusID(){
	document.form_.emp_id.focus();
} 
-->
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	boolean bolSingle = true;
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){%>
	<jsp:forward page="./form_2316_print.jsp"/>
<% return; }
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","emp_prev_salary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"emp_prev_salary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

	PRTaxReport prEmpInfo = new PRTaxReport();
	Vector vEmpInfo = null;
	Vector vEditInfo = null;
	Vector vDepInfo = null;
	Vector vEmployer  = null;
	Vector vPrevEmployer = null;
	String strEmpID = null;
	String strPageAction = WI.fillTextValue("page_action");
	double dTemp = 0d;
	boolean bolIsMWE = false;
	int iTemp = 0;
	
	String[] astrExemptionName    = {"Zero(No Exemption)", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 4 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
	
	if(strPageAction.length() > 0){
		if(prEmpInfo.operateOnEmployee2316(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = prEmpInfo.getErrMsg();
		else
			strErrMsg = "Operation successful";
	}
	 	
	vEmpInfo = prEmpInfo.getPersonalTaxInfo(dbOP, request, null);
	if(vEmpInfo == null)
		strErrMsg = prEmpInfo.getErrMsg();
	else{
		vDepInfo = (Vector)vEmpInfo.elementAt(9);
		vEmployer = (Vector)vEmpInfo.elementAt(10);
		vEditInfo = prEmpInfo.operateOnEmployee2316(dbOP, request, 4);
		vPrevEmployer = prEmpInfo.getPreviousEmployerInfo(dbOP, request, null, WI.fillTextValue("year_of"));
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(14);
			if(strTemp.equals("1"))
				bolIsMWE = true;
		}
  }
%>
<body onLoad="focusID();">
<form name="form_" action="./form_1601c.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF"  size="2"><strong>::::
		PAYROLL:  FORM 1601-C ENCODING ::::</strong></font></td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="23" colspan="3">&nbsp;<font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></td>
  </tr>
  <tr>
    <td width="3%" height="25">&nbsp;</td>
    <td width="19%">Employee ID</td>
		<%
				strEmpID = WI.fillTextValue("emp_id");
			%>
    <td><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <div style="position:absolute; overflow:auto; width:300px;">
				<label id="coa_info"></label>
			</div></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Salary period for Yr</td>
    <td><select name="month_of" onchange="ReloadPage();">
      <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
    </select>
    <select name="year_of" onChange="ReloadPage();">
        <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
    </select></td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td><!--<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>-->
			<font size="1">
<input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">			
Click to reload page.</font></td>
  </tr>
  <tr>
    <td height="10" colspan="3"><hr size="1" color="#0000FF"></td>
  </tr>
</table>
<%if(vEmpInfo != null && vEmpInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="30" colspan="3" valign="top">
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="marginBottom">      
      <tr>
        <td height="14" colspan="8" valign="top"><div >(To be filled up by the BIR)</div></td>
        </tr>
      <tr>
        <td width="41" height="14"  ><img src="images/arrow2.png" width="6" height="6" />DLN:</td>
          <td width="435"  ><div >
            <input name="textfield" type="text" id="textfield" style="width:350px; height:11px; text-align:left; border:1px #999999 solid"/>
          </div></td>
          <td width="14"  ><img src="images/arrow2.png" width="6" height="6" /></td>
          <td width="42"  >PSOC:</td>
          <td width="143"  ><div >
            <input name="textfield" type="text" id="textfield" style="width:114px; height:11px; text-align:left; border:1px #999999 solid"/>
          </div></td>
          <td width="11"  ><img src="images/arrow2.png" width="6" height="6" /></td>
          <td width="37"  >PSIC:</td>
          <td width="163"  ><input name="textfield" type="text" id="textfield" style="width:114px; height:11px; text-align:left; border:1px #999999 solid"/></td>
      </tr>
      
      
      
    </table>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC" class="container">
        <tr>
          <td width="100%" height="70" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="8%" height="66"  bgcolor="#FFFFFF"><img src="images/bir_logo.png" width="64" height="48" /></td>
                <td width="22%"  bgcolor="#FFFFFF"> Republika ng Pilipinas<br/>
                  Kagawaran ng Pananalapi<br/>
                  Kawanihan ng Rentas Internas </td>
                <td width="49%" bgcolor="#FFFFFF"><div align="center" class="textTitleHeader"> Monthly Remittance Return<br/>
                  of Income Taxes Withheld<br/>
                  on Compensation</div></td>
                <td width="21%"  bgcolor="#FFFFFF"><div > <span>BIR Form No.</span><br/>
                        <span class="textTitleHeader">1601-C</span><br/>
                  September 2001 (ENCS) </div></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td height="14" bgcolor="#FFFFFF"><div > Fill in all applicable spaces. Mark all appropriate boxes with an &quot;X&quot; </div></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="48" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="14%" height="14"><strong>1</strong> For the month</td>
                <td colspan="2" class="borderRight">&nbsp;</td>
                <td colspan="6"  class="borderRight"><strong>2</strong> Amended Return?</td>
                <td colspan="2"  class="borderRight"><strong>3</strong> No. of sheets attached</td>
                <td colspan="6"  ><strong>4</strong> Any Taxes Withheld</td>
              </tr>
              <tr>
                <td height="30"  valign="top">&nbsp;&nbsp;&nbsp;(MM/YYYY)</td>
                <td width="1%" height="30"  bgcolor="#CCCCCC" img="img"/bg1.gif><img src="images/arrow1.png" width="6" height="6" /></td>
                <%
								strTemp = WI.fillTextValue("month_of");
								iTemp = Integer.parseInt(strTemp) + 1;
								strTemp = Integer.toString(iTemp);								
								if(strTemp.length() == 1)
									strTemp = "0"+strTemp;
							%>
                <td width="20%"  class="borderRight"><input name="month_" type="text" value="<%=strTemp%>" maxlength="2" size="3" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
								readonly/>
                    <%
									strTemp = WI.fillTextValue("year_of");
								%>
                    <input name="year_" type="text" value="<%=strTemp%>" maxlength="4" size="5" class="textbox"
								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
								readonly/></td>
                <td width="4%" >&nbsp;</td>
                <td width="1%"  ><img src="images/arrow1.png" width="6" height="6" /></td>
                <%if(WI.fillTextValue("is_ammended").equals("1"))
										strTemp = "checked";
									else
										strTemp = "";
								%>
								<td width="3%"  ><input type="radio" name="is_ammended" value="1" <%=strTemp%>/></td>
                <td width="7%"  >Yes</td>
								<%
									if(strTemp.length() == 0)
										strTemp = "checked";
									else
										strTemp = "";
								%>								
                <td width="3%"  ><input type="radio" name="is_ammended" value="0" <%=strTemp%>/></td>
                <td width="4%"  class="borderRight">No</td>
                <td width="12%">&nbsp;</td>
								<%
									strTemp = WI.fillTextValue("addl_sheets");
								%>
                <td width="7%" class="borderRight">
								<input name="addl_sheets" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'"
								onblur="AllowOnlyFloat('form_','addl_sheets');style.backgroundColor='white'"
								onkeyup="AllowOnlyFloat('form_','addl_sheets');" style="text-align : right"
								value="<%=WI.getStrValue(strTemp,"0")%>" size="4" maxlength="3" /></td>
                <td width="4%">&nbsp;</td>
                <td width="1%"  ><img src="images/arrow1.png" width="6" height="6" /></td>
								<%
									strTemp = WI.fillTextValue("has_withheld");
									if(strTemp.equals("1"))
										strTemp = "checked";
									else
										strTemp = "";
								%>
                <td width="3%"  ><input type="radio" name="has_withheld" value="1" <%=strTemp%> /></td>
                <td width="7%"  >Yes</td>
								<%									
									if(strTemp.length() == 0)
										strTemp = "checked";
									else
										strTemp = "";
								%>
                <td width="3%"  ><input type="radio" name="has_withheld" value="0" <%=strTemp%> /></td>
                <td width="6%"  >No</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr background="images/bg1.gif">
                <td width="74" height="14"  bgcolor="#CCCCCC"><strong>Part I</strong></td>
                <td width="564" align="center" bgcolor="#CCCCCC"><strong>Background Information</strong></td>
                <td width="94" align="center" bgcolor="#CCCCCC">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC" class="borderBottom">
              <tr>
                <td height="37" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottomII">
                    <tr>
                      <td height="12"  ><strong>5</strong> TIN</td>
                      <td height="12"  >&nbsp;</td>
											<%
												strTemp = WI.fillTextValue("tin");
											%>
                      <td width="20%" rowspan="2"  >
											  <input name="tin" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox"
											onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
											readonly /></td>
                      <td><strong>6</strong> RDO Code</td>
                      <td>&nbsp;</td>
											<%
												strTemp = WI.fillTextValue("rdo_code");
											%>
                      <td width="14%" rowspan="2">
											<input name="rdo_code" type="text" value="<%=strTemp%>" maxlength="3" size="4" class="textbox"
											onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
                      <td width="14%" rowspan="2"  valign="top"><strong>7</strong> Line of Business/<br/>
                        Occupation</td>
                      <td width="2%"  >&nbsp;</td>
                      <%
												strTemp = WI.fillTextValue("business_line");
											%>
											<td width="33%" rowspan="2">
											<input name="business_line" type="text" value="<%=strTemp%>" maxlength="128" size="40" class="textbox"
			 								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
                    </tr>
                    <tr>
                      <td width="5%" height="12" align="right" ><img src="images/arrow1.png" width="6" height="6" /></td>
                      <td width="1%" align="right" >&nbsp;</td>
                      <td width="10%" height="12" align="right" ><img src="images/arrow1.png" width="6" height="6" /></td>
                      <td width="1%" align="right" >&nbsp;</td>
                      <td width="2%" align="right"  ><img src="images/arrow1.png" width="6" height="6" /></td>
                      </tr>
                </table>
								</td>
              </tr>
              <tr>
                <td height="49" valign="top">
								<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottomII">
                    <tr>
                      <td colspan="3"  class="borderRight"><strong>8</strong> Withholding Agent's Name (Last Name, First Name, Middle Name for Individuals)/(Registered Name for Non-Individual)</td>
                      <td height="21" colspan="2"  ><strong>9</strong> Telephone Number</td>
                    </tr>
                    <tr>
                      <td width="5%" align="right" ><img src="images/arrow1.png" width="6" height="6" /></td>
                      <td width="1%" align="right" >&nbsp;</td>
											<%
												strTemp = WI.fillTextValue("agent_name");
											%>
                      <td width="77%"  class="borderRight">
											<input name="agent_name" type="text" value="<%=strTemp%>" maxlength="128" size="64" class="textbox"
			 								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/>
											</td>
											<%
												strTemp = WI.fillTextValue("tel_no");
											%>
                      <td height="21" colspan="2">
                      <input name="tel_no" type="text" value="<%=strTemp%>" maxlength="7" size="8" class="textbox"
			 								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/>
                      </td>
                      </tr>
										<tr>
                      <td colspan="3" class="borderRight"><strong>10</strong> Registered Address</td>
                      <td height="21" colspan="2"  ><strong>11</strong> Zip Code</td>
                    </tr>
                    <tr>
                      <td width="5%" align="right" ><img src="images/arrow1.png" width="6" height="6" /></td>
                      <td width="1%" align="right" >&nbsp;</td>
											<%
											strTemp = WI.fillTextValue("agent_address");
											%>
                      <td width="77%"  class="borderRight"><input name="agent_address" type="text" value="<%=strTemp%>" maxlength="128" size="64" class="textbox"
			 								onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" style="width:auto"/></td>
                      <td width="2%" height="27" align="right" ><img src="images/arrow1.png" width="6" height="6" /></td>
                      <td width="15%"  ><input name="textfield22" type="text" id="textfield22" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="0000" maxlength="4"/></td>
                    </tr>
										<tr>
                      <td colspan="3"  class="borderRight"><table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                      <td height="18" colspan="6" rowspan="2"  class="borderRight"><strong>12</strong> Category of Withholding Agent</td>
                      <td colspan="6"><strong>13</strong> Are there payees availing tax relief under Special law</td>
                      </tr>
                    <tr>
                      <td>&nbsp;</td>
                      <td colspan="4">or International Tax Treaty?</td>
                      <td width="34%" rowspan="2"><input name="textfield2" type="text" id="textfield2" style="width:193px; height:15px; text-align:left; border:1px #999999 solid"/></td>
                    </tr>
                    <tr>
                      <td width="1%" height="26" align="right" ><img src="images/arrow1.png" width="6" height="6" /></td>
                      <td width="1%"  >&nbsp;</td>
                      <td width="4%"  ><input type="radio" name="radio2" id="radio" value="radio" /></td>
                      <td width="7%"  >Private</td>
                      <td width="4%"  ><input type="radio" name="radio2" id="radio" value="radio" /></td>
                      <td width="15%"  class="borderRight">Government</td>
                      <td width="4%"  ><input type="radio" name="radio3" id="radio" value="radio" /></td>
                      <td width="7%"  >Yes</td>
                      <td width="3%"  ><input type="radio" name="radio3" id="radio" value="radio" /></td>
                      <td width="6%"  >No</td>
                      <td width="14%"  >If yes, specify</td>
                      </tr>
                </table>
										</td>
                      <td height="21" colspan="2"  ><table width="100%" border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td colspan="2"><strong>14</strong> ATC </td>
                            </tr>
                          <tr>
                            <td width="13%" align="right"><img src="images/arrow1.png" width="6" height="6" /></td>
                            <td width="87%"><input name="textfield23" type="text" id="textfield23" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="0000000" maxlength="5"/></td>
                          </tr>
                        </table></td>
                    </tr>
                </table></td>
              </tr>
              
              <tr>
                <td height="44" valign="top"></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="74" height="15"  ><strong>Part II</strong></td>
                <td width="564" align="center"><img src="images/arrow1.png" width="6" height="6" /><strong>Computation of Tax</strong></td>
                <td width="94"  >&nbsp;</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="221" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td height="17" colspan="5" align="center"><strong>Particulars</strong></td>
                <td colspan="5" align="center"><strong>Amount of Compensation</strong></td>
                <td colspan="2" align="center"><strong>Tax Due</strong></td>
              </tr>
              <tr>
                <td height="17" colspan="5"  ><strong>15</strong> Total amount of Compensation</td>
                <td width="2%"  ><strong>15</strong></td>
                <td colspan="4"  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
                <td colspan="2"  ></td>
              </tr>
              <tr>
                <td height="17" colspan="5"  ><strong>16</strong> Less: Non Taxable Compensation </td>
                <td  ><strong>16</strong></td>
                <td colspan="4"  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
                <td colspan="2"  ></td>
              </tr>
              <tr>
                <td height="17" colspan="5"  ><strong>17</strong> Taxable Compensation </td>
                <td  ><strong>17</strong></td>
                <td colspan="4"  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
                <td colspan="2"  ></td>
              </tr>
              <tr>
                <td height="17" colspan="10"  ><strong>18</strong> Tax Required to be Withheld </td>
                <td width="2%"  ><strong>18</strong></td>
                <td width="30%"  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="17" colspan="10"  ><strong>19</strong> Add/Less: Adjustment (from Item 25 of Section A) </td>
                <td  ><strong>19</strong></td>
                <td  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="17" colspan="10"  ><strong>20</strong> Tax Required to be Withheld for Remittance </td>
                <td  ><strong>20</strong></td>
                <td  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="17" colspan="10"  ><strong>21</strong> Less: Tax Previously Remitted in Return Previously Filed, if this is an ammended return </td>
                <td  ><strong>21</strong></td>
                <td  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="17" colspan="10"  ><strong>22</strong> Tax Still Due/(Overremittance) </td>
                <td  ><strong>22</strong></td>
                <td  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="14" colspan="12"  ><strong>23</strong> Add: Penalties</td>
              </tr>
              <tr>
                <td width="6%" height="14"  valign="top">&nbsp;</td>
                <td colspan="2" align="center"><strong>Surcharge</strong></td>
                <td colspan="4" align="center"><strong>Interest</strong></td>
                <td colspan="2" align="center"><strong>Compromise</strong></td>
                <td colspan="3"  valign="top">&nbsp;</td>
              </tr>
              <tr>
                <td height="19"  valign="top">&nbsp;</td>
                <td width="2%"  ><strong>23A</strong></td>
                <td width="12%"  ><input name="textfield2" type="text" id="textfield2" style="width:119px; height:15px; text-align:left; border:1px #999999 solid"/></td>
                <td width="2%"  ><strong>23B</strong></td>
                <td colspan="3"  ><input name="textfield2" type="text" id="textfield2" style="width:119px; height:15px; text-align:left; border:1px #999999 solid"/></td>
                <td width="2%"  ><strong>23C</strong></td>
                <td width="12%"  ><input name="textfield2" type="text" id="textfield2" style="width:119px; height:15px; text-align:left; border:1px #999999 solid"/></td>
                <td colspan="2" align="center" valign="top"><strong>23D</strong></td>
                <td  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="17" colspan="10"  ><strong>24</strong> Total Amount Still Due/(Overremittance) </td>
                <td  ><strong>24</strong></td>
                <td  ><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:right; border:1px #999999 solid" value="999999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="0"></td>
                <td></td>
                <td></td>
                <td></td>
                <td width="0%"></td>
                <td></td>
                <td width="11%"></td>
                <td></td>
                <td></td>
                <td width="19%"></td>
                <td></td>
                <td></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="74" height="14"  bgcolor="#CCCCCC"><strong>Section A</strong></td>
                <td width="564" align="center" bgcolor="#CCCCCC"><strong>Adjustment of Taxes Withheld on Compensation For Previous Months</strong></td>
                <td width="94" align="center" bgcolor="#CCCCCC">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="151" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td height="57" colspan="2" align="center" class="borderRightBottom"> Previous Month(s)<br/>
                  (1)<br/>
                  (MM/YYYY)</td>
                <td colspan="3" align="center" class="borderRightBottom"> Date Paid<br/>
                  (2)<br/>
                  (MM/DD/YYYY)</td>
                <td width="25%" align="center" class="borderRightBottom"> Bank Validation/<br/>
                  ROR No.<br/>
                  (3)</td>
                <td width="25%" align="center" class="borderBottomII"> Bank Code<br/>
                  (4)<br/>
                  &nbsp;</td>
              </tr>
              <tr>
                <td width="6%" height="29" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td width="19%" height="29" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td width="5%" height="29" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td width="6%" height="29" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="DD" maxlength="2"/></td>
                <td width="14%" height="29" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="29" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td height="29" align="center" class="borderBottomII"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="31" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td height="31" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="31" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td height="31" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="DD" maxlength="2"/></td>
                <td height="31" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="31" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td height="31" align="center" class="borderBottomII"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="30" align="center" class="borderRight"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td height="30" align="center" class="borderRight"><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="30" align="center" class="borderRight"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td height="30" align="center" class="borderRight"><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="DD" maxlength="2"/></td>
                <td height="30" align="center" class="borderRight"><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="30" align="center" class="borderRight"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td height="30" align="center"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="151" height="14"  bgcolor="#CCCCCC"><strong>Section A  (Continuation)</strong></td>
                <td width="487" align="center" bgcolor="#CCCCCC">&nbsp;</td>
                <td width="94" align="center" bgcolor="#CCCCCC">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="178" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="25%" rowspan="2" align="center" class="borderRightBottom"> Tax Paid (Excluding Penalties)<br/>
                  for the month<br/>
                  (5)</td>
                <td colspan="2" rowspan="2" align="center" class="borderRightBottom"> Should Be Tax Due<br/>
                  for the Month<br/>
                  (6)</td>
                <td height="23" colspan="2" align="center" class="borderBottomII">Adjustment (7)</td>
              </tr>
              <tr>
                <td width="24%" height="29" align="center" class="borderRightBottom">From Current Year <br/>
                  (7a)</td>
                <td width="26%" align="center" class="borderBottomII"> From Year - End Adjustment of the<br/>
                  Immediately Preceeding Year (7a)</td>
              </tr>
              <tr>
                <td height="28" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td colspan="2" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td align="center" class="borderBottomII"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="27" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td colspan="2" align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td align="center" class="borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td align="center" class="borderBottomII"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="40" align="center" class=" borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td colspan="2" align="center" class=" borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td align="center" class=" borderRightBottom"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
                <td align="center" class="borderBottomII"><input name="textfield2" type="text" id="textfield2" style="width:130px; height:15px; text-align:left; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="27" colspan="2"  ><strong>25</strong> Total (7a plus 7b) (To Item 19)</td>
                <td colspan="3" align="center"><input name="textfield2" type="text" id="textfield2" style="width:220px; height:15px; text-align:left; border:1px #999999 solid" value="99999999" maxlength="9"/></td>
              </tr>
              <tr>
                <td height="0"></td>
                <td width="17%"></td>
                <td></td>
                <td></td>
                <td></td>
              </tr>
              <tr>
                <td height="1"></td>
                <td></td>
                <td width="8%"></td>
                <td></td>
                <td></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="145" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td height="45" colspan="2" align="center"> I declare, under the penalties of perjury, that this return has been made in good faith, verified me, and to the best of my knowledge and belief, is true and correct, pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.</td>
              </tr>
              <tr>
                <td width="364" height="22" align="center"><strong>26</strong>&nbsp;
                    <input name="textfield2" type="text" id="textfield2" style="width:280px; height:15px; text-align:left; border:1px #999999 solid"/></td>
                <td width="368" align="center"><strong>27</strong>&nbsp;
                    <input name="textfield2" type="text" id="textfield2" style="width:280px; height:15px; text-align:left; border:1px #999999 solid"/></td>
              </tr>
              <tr>
                <td height="23" align="center"> Signature over printed name of Taxpayer/<br/>
                  Authorized Representative</td>
                <td width="368" align="center">Title/Position of Signatory</td>
              </tr>
              <tr>
                <td height="23" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <input name="textfield2" type="text" id="textfield2" style="width:280px; height:15px; text-align:left; border:1px #999999 solid"/></td>
                <td height="23" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <input name="textfield2" type="text" id="textfield2" style="width:280px; height:15px; text-align:left; border:1px #999999 solid"/></td>
              </tr>
              <tr>
                <td height="23" align="center">TIN of Tax Agent (If applicable)</td>
                <td height="23" align="center">Tax Agent Accreditation No. (If applicable)</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="74" height="15"  bgcolor="#CCCCCC"><strong>Part III</strong></td>
                <td width="564" align="center" bgcolor="#CCCCCC"><strong>Details of Payment</strong></td>
                <td width="94" align="center" bgcolor="#CCCCCC">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="131" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
              <tr>
                <td width="109" height="27" rowspan="2" align="center" valign="bottom" class="borderRightBottom"><strong >Particulars</strong></td>
                <td colspan="2" rowspan="2" align="center" class="borderRightBottom"><strong>Drawee Bank/<br/>
                  Agency</strong></td>
                <td colspan="2" rowspan="2" align="center" valign="bottom" class="borderRightBottom"><strong>Number</strong></td>
                <td align="center">&nbsp;</td>
                <td align="center" class="borderBottomII">&nbsp;</td>
                <td align="center" class="borderBottomII"><strong>Date</strong></td>
                <td align="center" class="borderRightBottom">&nbsp;</td>
                <td colspan="2" rowspan="2" align="center" valign="bottom" class="borderBottomII"><strong >Amount</strong></td>
                <td width="128" rowspan="5" align="center" valign="top" class="borderLeft">Stamp of Receiving<br/>
                  Office and Date of<br/>
                  Receipt</td>
              </tr>
              <tr>
                <td align="center" class="borderRightBottom">&nbsp;</td>
                <td align="center" class="borderRightBottom"><strong>MM</strong></td>
                <td width="42" align="center" class="borderRightBottom"><strong>DD</strong></td>
                <td width="53" align="center" class="borderRightBottom"><strong>YYYY</strong></td>
              </tr>
              <tr>
                <td height="33"  valign="top"><strong>28</strong> Cash/Bank<br/>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Debit Memo</td>
                <td height="17" colspan="2"  >&nbsp;</td>
                <td height="17" colspan="2"  >&nbsp;</td>
                <td height="17" colspan="4"  >&nbsp;</td>
                <td width="19" height="17" align="right" ><strong>28</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td width="113"  ><input name="textfield2" type="text" id="textfield2" style="width:100px; height:15px; text-align:right; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="34"  ><strong>29</strong> Check</td>
                <td width="21" height="16" align="right" ><strong>29A</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td width="84" height="16"  ><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="00000" maxlength="5"/></td>
                <td width="24" height="16" align="right" ><strong>29B</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td width="71"  ><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="00000" maxlength="5"/></td>
                <td width="23" height="16" align="right" ><strong>29C</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td width="45"  ><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td height="16"  ><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="DD" maxlength="2"/></td>
                <td height="16"  ><input name="textfield2" type="text" id="textfield2" style="width:45px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="16" align="right" ><strong>29D</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td height="16"  ><input name="textfield2" type="text" id="textfield2" style="width:100px; height:15px; text-align:right; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
              <tr>
                <td height="30"  ><strong>30</strong> Others</td>
                <td height="30" align="right" ><strong>30A</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td height="30"  ><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="00000" maxlength="5"/></td>
                <td height="30" align="right" ><strong>30B</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td height="30"  ><input name="textfield2" type="text" id="textfield2" style="width:60px; height:15px; text-align:left; border:1px #999999 solid" value="00000" maxlength="5"/></td>
                <td height="30" align="right" ><strong>30C</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td height="30"  ><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="MM" maxlength="2"/></td>
                <td height="30"  ><input name="textfield2" type="text" id="textfield2" style="width:32px; height:15px; text-align:left; border:1px #999999 solid" value="DD" maxlength="2"/></td>
                <td height="30"  ><input name="textfield2" type="text" id="textfield2" style="width:45px; height:15px; text-align:left; border:1px #999999 solid" value="YYYY" maxlength="4"/></td>
                <td height="30" align="right" ><strong>29D</strong><br/>
                    <img src="images/arrow1.png" /></td>
                <td height="30"  ><input name="textfield2" type="text" id="textfield2" style="width:100px; height:15px; text-align:right; border:1px #999999 solid" value="1234567890" maxlength="10"/></td>
              </tr>
          </table></td>
        </tr>
        <tr>
          <td height="56" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td width="732" height="57"  valign="top" bgcolor="#FFFFFF">Machine Validation/Revenue Official Receipt Details(If not files with the bank)</td>
              </tr>
          </table></td>
        </tr>
      </table></td>
  </tr>
	
  <tr>
    <td width="29%" rowspan="3" align="center"></td>
    <td height="14" align="center"></td>
    <td width="34%" rowspan="3" align="center"></td>
  </tr>
  <tr>
    <td width="37%" height="26" align="center"><img src="images/print.png" width="31" height="26" align="absmiddle" hspace="3"/>Print this Form</td>
  </tr>
  <tr>
    <td height="24" align="center"><input name="print" type="button" value="Print" /></td>
  </tr>
  <tr>
    <td height="31" colspan="3" align="center" valign="top">&nbsp;</td>
  </tr>
  </table>
	<%}%>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="print_pg">
</form>	
</body>
</html>
<%
dbOP.cleanUP();
%>