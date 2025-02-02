<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#D2AE72">
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          FIXED ASSETS &amp; DEPRECIATION - ADD/CREATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4"><font size="1"><a href="fixed_assets_depre_page1.jsp" target="_self"><img src="../../../images/go_back.gif" border="0"></a>
        click to go back to Operation Menu Page</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><input type="checkbox" name="checkbox" value="checkbox">
        Academic &nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox2" value="checkbox">
        Non-Academic</td>
      <td width="47%" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="15">&nbsp;</td>
      <td height="15" colspan="2" valign="bottom">College</td>
      <td height="15" valign="bottom">Department</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="select3">
        </select></td>
      <td><select name="select4">
        </select></td>
    </tr>
    <tr>
      <td height="15">&nbsp;</td>
      <td width="29%">Non-Acad Office/Department</td>
      <td width="23%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="select">
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="21%">Asset Type</td>
      <td colspan="2"> <select name="select2">
          <option>Buildings</option>
          <option>Computers</option>
          <option>Equipment</option>
          <option>Land Proporties</option>
        </select> <font size="1"><a href="fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/update.gif" border="0"></a>click
        to update asset type list</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Asset Description </td>
      <td width="40%"><textarea name="textarea" cols="32" rows="3"></textarea></td>
      <td width="38%" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Paid</td>
      <td> <input name="textfield2" type="text" size="10"> <font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Principal</td>
      <td><input name="textfield3" type="text" size="16">
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Life</td>
      <td><input name="textfield6" type="text" size="3">
        month(s) </td>
      <td>&nbsp; </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Monthly Depreciation </td>
      <td><strong>$dep_monthly</strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Asset Status</td>
      <td><select name="select6">
          <option>Current</option>
          <option>Sold</option>
          <option>Donated</option>
          <option>Discarded</option>
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Total Dep. to Date</td>
      <td colspan="2"><strong>$tot_dep </strong>&lt;total dep value from date
        paid to current date&gt;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Present Value</td>
      <td colspan="2"><strong>$present_value </strong>&lt;present value=principal
        - total depreciation&gt;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><font size="1"><a href="fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/save.gif" border="0"></a>click
        to save entries&nbsp;&nbsp;&nbsp; <a href="fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/cancel.gif" border="0"></a>click
        to cancel/clear entries</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="10" bgcolor="#B9B292"><div align="center">LIST
          OF ASSET(S)</div></td>
    </tr>
    <tr>
      <td width="18%" height="25"><div align="center"><font size="1"><strong>
          ASSET TYPE</strong></font></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>ASSET DESCRIPTION</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>DATE PAID</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>PRINCIPAL</strong></font></div></td>
      <td width="4%"><div align="center"><font size="1"><strong>LIFE</strong></font></div></td>
      <td width="6%"><div align="center"><font size="1"><strong>MONTHLY DEP.</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>ASSET STATUS</strong></font></div></td>
      <td width="5%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><font size="1">Buildings</font></td>
      <td><font size="1">Hospital with 4 floors</font></td>
      <td><font size="1">09/14/2004</font></td>
      <td><font size="1">11,123,456.78</font></td>
      <td><font size="1">123</font></td>
      <td><font size="1">123,456.78</font></td>
      <td><font size="1">CURRENT</font></td>
      <td><font size="1"><a href="fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/view.gif" border="0"></a></font></td>
      <td><font size="1"><a href="fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/edit.gif" border="0"></a></font></td>
      <td><font size="1"><a href="fixed_assets_depre_update_type.jsp" target="_self"><img src="../../../images/delete.gif" border="0"></a></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="22">&nbsp;</td>
      <td colspan="4" height="22">&nbsp;</td>
      <td height="22" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="left"><font size="1"><a href="../../fee_assess_pay/reports/statement_of_account_print.htm" target="_blank"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list of assets</font></font></div></td>
      <td width="1%" height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
